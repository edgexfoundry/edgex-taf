import json
import math
import threading
import psutil
import time
import requests
import http.client
import paho.mqtt.client as mqtt
from robot.api import logger

from TAF.config.modbus_scalability_test import configuration
from TAF.config import global_variables
from TAF.testCaseModules.keywords.setup import edgex
from TUC.data.SettingsInfo import SettingsInfo

psutil.PROCFS_PATH = configuration.PROC_PATH
accumulated_event_amount = 0
lock = threading.Lock()


class ReportInfo:
    def __init__(self, logical_cpus,physical_cpus, cpu_freq, memory ,test_spent_time):
        self.logical_cpus = logical_cpus
        self.physical_cpus = physical_cpus
        self.cpu_freq = cpu_freq
        self.memory = memory
        self.test_spent_time = test_spent_time


class ResourceUtilization:
    def __init__(self, case_no, device_amount,
                 cpu1, mem1,cpu2, mem2,
                 expected_accumulated_event_amount1=0, accumulated_event_amount1=0,
                 expected_accumulated_event_amount2=0, accumulated_event_amount2=0):
        self.case_no = case_no
        self.device_amount = device_amount

        self.cpu1 = cpu1
        self.mem1 = mem1
        self.expected_accumulated_event_amount1 = expected_accumulated_event_amount1
        self.accumulated_event_amount1 = accumulated_event_amount1

        self.cpu2 = cpu2
        self.mem2 = mem2
        self.expected_accumulated_event_amount2 = expected_accumulated_event_amount2
        self.accumulated_event_amount2 = accumulated_event_amount2


def on_connect(client, userdata, flags, rc):
    logger.info("▶ Connected to MQTT broker with result code " + str(rc), also_console=True)
    client.subscribe("edgex-events")


def on_message(client, userdata, msg):
    lock.acquire()
    # logger.info(msg.payload.decode(), also_console=True)
    if "origin" in msg.payload.decode():
        global accumulated_event_amount
        accumulated_event_amount += 1
    lock.release()


def initial_mqtt_client(mqtt_client):
    logger.info('Connect to the MQTT broker...', also_console=True)
    port = 1883
    try:
        mqtt_client.connect(host=configuration.MQTT_BROKER_IP, port=port, keepalive=60)
    except Exception as err:
        raise Exception('fail to connect the MQTT broker, IP:{} Port:{}, {}'.format(configuration.MQTT_BROKER_IP, port, err))

    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message


# fetch_report_info fetches the system information via psutil (https://pypi.org/project/psutil/)
def fetch_report_info():
    logger.info("cpu_count: {}".format(psutil.cpu_count()), also_console=True)
    logger.info("cpu_freq: {}".format(psutil.cpu_freq()), also_console=True)
    logger.info("virtual_memory: {}".format(psutil.virtual_memory()), also_console=True)

    cpu_freq = 0
    # The cpu_freq is None in some Virtual machine
    if psutil.cpu_freq() is not None:
        cpu_freq = psutil.cpu_freq().max
    report_info = ReportInfo(
        logical_cpus=psutil.cpu_count(),
        physical_cpus=psutil.cpu_count(logical=False),
        cpu_freq=cpu_freq,
        memory=round(psutil.virtual_memory().total / math.pow(2, 30), 1),
        test_spent_time=0
    )

    return report_info


def when_run_scalability_testing():
    logger.info('● Run the scalability testing', also_console=True)
    test_start_time = time.time()

    report_info = fetch_report_info()

    records = []
    created_devices = []
    next_port = configuration.STARTING_PORT
    device_increment = configuration.DEVICE_INCREMENT
    times = int(configuration.SIMULATOR_NUMBER / device_increment)  # The loop times

    mqtt_client = mqtt.Client()

    try:
        initial_mqtt_client(mqtt_client)
        mqtt_client.loop_start()
        reset_simulator_reading_count()

        for i in range(times):
            case_no = i + 1
            device_amount = case_no * device_increment

            # Create 10 device
            devices = create_devices(device_increment, next_port)
            created_devices.extend(devices)  # created_devices list is used to clean data after testing

            # Start the device service
            logger.info('▶ Start the device service {}'.format(configuration.SERVICE_NAME), also_console=True)
            update_device_service_admin_state("UNLOCKED")

            # Fetch and record ResourceUtilization which is used to generate the report later
            logger.info('▶ Fetch the resource utilization with {} devices'.format(device_amount), also_console=True)
            resource_utilization = fetch_metric(case_no, device_amount)

            # Stop the device service for calculating the event amount
            logger.info('▶ Stop the device service {}'.format(configuration.SERVICE_NAME), also_console=True)
            update_device_service_admin_state("LOCKED")
            time.sleep(20)

            resource_utilization.accumulated_event_amount2 = accumulated_event_amount

            # Query modbus simulator to get the current reading amount
            resource_utilization.expected_accumulated_event_amount2 = int(query_simulator_reading_count()/10)

            records.append(resource_utilization)

            logger.info('▶▶ CPU1 {}% with MEM1 {}%'.format(
                resource_utilization.cpu1,resource_utilization.mem1), also_console=True)
            logger.info('▶▶ CPU2 {}% with MEM2 {}%'.format(
                resource_utilization.cpu2, resource_utilization.mem2), also_console=True)
            logger.info('▶▶ Expected event amount {}'.format(
                resource_utilization.expected_accumulated_event_amount2), also_console=True)
            logger.info('▶▶ Actual event amount {}'.format(
                resource_utilization.accumulated_event_amount2), also_console=True)

            # Check if utilization exceed the threshold, the function will throw an error
            check_threshold(resource_utilization)

            # Add increment for next loop
            next_port = next_port + device_increment

    except Exception as err:
        logger.error('☉ Stop the testing due to the error, {}'.format(err))
    finally:
        remove_created_devices(created_devices)
        mqtt_client.disconnect()
        mqtt_client.loop_stop()
        logger.info('☉ The total received event amount:{}'.format(accumulated_event_amount), also_console=True)

    test_end_time = time.time()
    report_info.test_spent_time = test_end_time - test_start_time
    return report_info, records


def create_devices(amount, starting_port):
    devices = []
    for i in range(amount):
        port = starting_port + i
        device = create_device_with_port(port)
        time.sleep(0.5)
        devices.append(device)
    return devices


# fetch_metric fetches CPU and memory twice for threshold checking
def fetch_metric(case_no, device_amount):
    global accumulated_event_amount

    logger.debug('▷ Sleep {} seconds for autoEvent working at first minute'.format(configuration.SLEEP_INTERVAL))
    time.sleep(configuration.SLEEP_INTERVAL)

    logger.debug('▷ Fetch metric for case {}'.format(case_no))
    cpu_utilization1 = psutil.cpu_percent(interval=1)
    mem_utilization1 = psutil.virtual_memory().percent

    logger.debug('▷ Sleep {} seconds for autoEvent working at second minute'.format(configuration.SLEEP_INTERVAL))
    time.sleep(configuration.SLEEP_INTERVAL)

    logger.debug('▷ Fetch metric for case {}'.format(case_no))
    cpu_utilization2 = psutil.cpu_percent(interval=1)
    mem_utilization2 = psutil.virtual_memory().percent

    return ResourceUtilization(
        case_no='case-{}'.format(case_no),
        device_amount=device_amount,
        cpu1=cpu_utilization1,
        mem1=mem_utilization1,
        cpu2=cpu_utilization2,
        mem2=mem_utilization2,
    )


# check_threshold check whether the system metrics are within the expected value, if not it raises a Exception
def check_threshold(resource_utilization):
    # if Maximum CPU utilization greater than expected
    if resource_utilization.cpu1 >= configuration.THRESHOLD_CPU_UTILIZATION or resource_utilization.cpu2 >= configuration.THRESHOLD_CPU_UTILIZATION:
        raise Exception('☉ Stop the testing due to the CPU utilization {} is full.'.format(resource_utilization.cpu2))

    # if memory utilization greater than expected
    if resource_utilization.mem2 > configuration.THRESHOLD_MEMORY_UTILIZATION:
        raise Exception(
            '☉ Stop the testing due to the memory utilization {} is higher than {}%.'.format(
                resource_utilization.mem2,
                configuration.THRESHOLD_MEMORY_UTILIZATION))

    # if Memory usage growth than expected
    if (resource_utilization.mem2 - resource_utilization.mem1) > configuration.THRESHOLD_MEMORY_USAGE_GROWTH:
        raise Exception(
            '☉ Stop the testing due to the memory usage growth than {}%, {} - {} > {}'.format(
                configuration.THRESHOLD_MEMORY_USAGE_GROWTH,
                resource_utilization.mem2, resource_utilization.mem1,
                configuration.THRESHOLD_MEMORY_USAGE_GROWTH))

    # if the actual events is not equal to the expected
    if resource_utilization.accumulated_event_amount2 != resource_utilization.expected_accumulated_event_amount2:
        raise Exception(
            '☉ Stop the testing due to the actual event amount {} not equal the expected {}'.format(
                resource_utilization.accumulated_event_amount2, resource_utilization.expected_accumulated_event_amount2))


def create_device_with_port(port):
    device = {
        "name": "device-{}".format(port),
        "description": "mock device with port {}".format(port),
        "adminState": "UNLOCKED",
        "operatingState": "ENABLED",
        "protocols": {
            "modbus-tcp": {
                "Address": configuration.SIMULATOR_HOST,
                "Port": str(port),
                "UnitID": "1"
            }
        },
        "service": {
            "name": configuration.SERVICE_NAME
        },
        "profile": {
            "name": configuration.DEVICE_PROFILE_NAME
        },
        "autoEvents": [
            {
                "frequency": "1s",
                "resource": "integerA"
            },
            {
                "frequency": "2s",
                "resource": "integerB"
            },
            {
                "frequency": "3s",
                "resource": "booleanA"
            },
            {
                "frequency": "4s",
                "resource": "booleanB"
            }
        ]
    }

    logger.debug('▶ Created device {}'.format(json.dumps(device)))

    conn = http.client.HTTPConnection(host=SettingsInfo().constant.BASE_URL, port=global_variables.CORE_METADATA_PORT, timeout=5)
    conn.request(method="POST", url="/api/{}/device".format(global_variables.API_VERSION), body=json.dumps(device))
    try:
        r = conn.getresponse()
    except Exception as e:
        raise e
    if int(r.status) == 200:
        logger.debug('▶ Create device {} successfully'.format(device["name"]))
    else:
        logger.error('▶ Fail to create the device {}. {}'.format(device["name"], r.read()))

    logger.debug('▶ Created device with the profile "{}" port "{}" '.format(configuration.DEVICE_PROFILE_NAME, port))

    return device


def remove_created_devices(created_devices):
    logger.info('▶ Test finished, clean devices', also_console=True)
    url = '{}://{}:{}/api/{}/device/name'.format(
        global_variables.URI_SCHEME,
        global_variables.BASE_URL,
        global_variables.CORE_METADATA_PORT,
        global_variables.API_VERSION
    )
    for i in range(len(created_devices)):
        try:
            res = requests.delete('{}/{}'.format(url, created_devices[i]["name"]))
            res.raise_for_status()
        except Exception as e:
            logger.error('▶ Fail to remove device by name {}, {}'.format(created_devices[i]["name"], e))


def reset_simulator_reading_count():
    try:
        logger.info('▶ Reset simulator reading count.', also_console=True)
        conn = http.client.HTTPConnection(host=configuration.SIMULATOR_HOST, port=1503, timeout=10)
        conn.request(method="GET", url="/reading/count/reset")
        r = conn.getresponse()
    except Exception as e:
        logger.debug('▶ Fail to reset simulator reading count. {}'.format(e))
        raise e
    if int(r.status) == 200:
        logger.info('▶ Reset simulator reading count to 0', also_console=True)
    else:
        logger.error('▶ Fail to reset simulator reading count.')
        raise Exception('Fail to reset simulator reading count.')


def query_simulator_reading_count():
    try:
        conn = http.client.HTTPConnection(host=configuration.SIMULATOR_HOST, port=1503, timeout=10)
        conn.request(method="GET", url="/reading/count")
        r = conn.getresponse()
    except Exception as e:
        logger.debug('▶ Fail to query simulator reading count. {}'.format(e))
        raise e
    if int(r.status) == 200:
        count = int(r.read())
        logger.info('▶ Query simulator reading count {}'.format(count), also_console=True)
        return count
    else:
        logger.error('▶ Fail to reset simulator reading count.')
        raise Exception("Fail to query simulator reading count.")


def update_device_service_admin_state(admin_state):
    conn = http.client.HTTPConnection(host=SettingsInfo().constant.BASE_URL, port=59881, timeout=5)
    conn.request(method="PUT",
                 url="/api/{}/deviceservice/name/{}/adminstate/{}".format(global_variables.API_VERSION, configuration.SERVICE_NAME, admin_state))
    try:
        r1 = conn.getresponse()
    except Exception as e:
        raise e
    if int(r1.status) == 200:
        logger.debug('▶ Update device service admin state to {}'.format(admin_state))
    else:
        logger.error('▶ Fail to update the admin state.')
        raise Exception('Fail to update the admin state')
