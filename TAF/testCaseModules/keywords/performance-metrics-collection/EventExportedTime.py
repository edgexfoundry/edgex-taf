import math
import json
import subprocess
from robot.api import logger
from TUC.data.SettingsInfo import SettingsInfo
import data_utils

global result, devices
result = {
        "devices": {},
        "total_average_exported_time": 0
}

devices = ["Random-Integer-Device", "Random-Boolean-Device", "Random-UnsignedInteger-Device"]


class EventExportedTime(object):
    def retrieve_events_from_subscriber(self):
        SettingsInfo().TestLog.info("Run Subscriber And Get Events")
        # run EXPORTED_LOOP_TIMES + 2 times and remove max and min values
        times = SettingsInfo().profile_constant.EXPORTED_LOOP_TIMES + 2
        device_int = []
        device_bool = []
        device_uint = []

        full_subscriber_logs = subprocess.check_output(
            "python {}/TAF/utils/src/setup/mqtt-subscriber.py edgex-events origin {} false -1 {}".format(
                SettingsInfo().workDir, SettingsInfo().constant.BROKER_PORT,
                SettingsInfo().profile_constant.SUBSCIBE_DURATION), shell=True)
        subscriber_logs = full_subscriber_logs.decode("utf-8").replace("Connected to MQTT with result code 0", "")
        messages = subscriber_logs.split('Got message!!')
        for message in messages:
            if "deviceName" in message:
                full_msg_list = message.split('\n')
                msg_list = list(filter(None, full_msg_list))  # Remove empty value
                for line in msg_list:
                    if "origin" in line:
                        event_json = json.loads(line)
                        event_json['received'] = int(msg_list[0])

                if str(devices[0]) == event_json['deviceName']:
                    device_int.append(event_json)
                elif str(devices[1]) == event_json['deviceName']:
                    device_bool.append(event_json)
                elif str(devices[2]) == event_json['deviceName']:
                    device_uint.append(event_json)
                else:
                    continue

        result["devices"][devices[0]] = device_int[-times:]
        result["devices"][devices[1]] = device_bool[-times:]
        result["devices"][devices[2]] = device_uint[-times:]

    def fetch_the_exported_time(self):
        events = []
        global events_exported_time_list
        events_exported_time_list = {}
        for device in result["devices"]:
            events_exported_time_list[device] = []
            for event in result["devices"][device]:
                event["origin"] = get_origin_time(event["origin"])
                event["exported"] = event["received"] - event["origin"]
                events.append(event)
                events_exported_time_list[device].append(event["exported"])
            # eliminate the max and main values from events_exported_time_list, events and result
            max_index = events_exported_time_list[device].index(max(events_exported_time_list[device]))
            min_index = events_exported_time_list[device].index(min(events_exported_time_list[device]))
            max_item = result["devices"][device][max_index]
            min_item = result["devices"][device][min_index]
            events_exported_time_list[device].remove(max(events_exported_time_list[device]))
            events_exported_time_list[device].remove(max(events_exported_time_list[device]))
            events.remove(max_item)
            events.remove(min_item)
            result["devices"][device].remove(max_item)
            result["devices"][device].remove(min_item)
            
        total_exported_time = 0
        for e in events:
            total_exported_time += e["exported"]

        if total_exported_time != 0:
            result["total_average_exported_time"] = total_exported_time / len(events)

    def exported_time_is_less_than_threshold_value(self):
        compare_export_time_with_threshold()

    def show_the_summary_table(self):
        show_the_summary_table_in_html()

    def show_the_aggregation_table(self):
        global devices_aggregate_values_list
        devices_aggregate_values_list = get_devices_aggregate_values()
        show_the_aggregation_table_in_html(devices_aggregate_values_list)


# check origin time is nanoseconds level and convert to milliseconds level
def get_origin_time(origin_time):
    if origin_time > math.pow(10, 18):
        origin_time = int(origin_time / math.pow(10, 6))

    return origin_time


def compare_export_time_with_threshold():
    for device in result["devices"]:
        for event in result["devices"][device]:
            compare_value = int(SettingsInfo().profile_constant.EXPORT_TIME_THRESHOLD)
            if event["exported"] == "":
                continue
            else:
                if compare_value < event["exported"]:
                    raise Exception("{} event exported time is longer than {} ms".format(device,
                                    SettingsInfo().profile_constant.EXPORT_TIME_THRESHOLD))
    return True


def show_the_summary_table_in_html():
    html = """ 
    <h3 style="margin:0px">Event exported time:</h3>
    <div style="margin:0px">Total average exported time: {} ms</div>
    <table style="border: 1px solid black;white-space: initial;"> 
        <tr style="border: 1px solid black;">
            <th style="border: 1px solid black;">
                Device			 	 
            </th>
            <th style="border: 1px solid black;" colspan="5">
                Event exported time ( received - origin )
            </th>
        </tr>
    """.format(result["total_average_exported_time"])

    for device in result["devices"]:
        html = html + """ 
        <tr style="border: 1px solid black;">
            <td style="border: 1px solid black;">
                {}			 	 
            </td>
            """.format(device)

        for event in result["devices"][device]:
            if event["exported"] == "":
                html = html + """<td style="border: 1px solid black;"> N/A </td>"""
            else:
                html = html + """ 
                        <td style="border: 1px solid black;">{} ms <br/>({} - {})</td>
                    """.format(event["exported"], event["received"], event["origin"])

        html = html + "</tr>"

    html = html + "</table>"
    logger.info(html, html=True)


def show_the_aggregation_table_in_html(devices_aggregate_list):
    html = """ 
    <h3 style="margin:0px">Event exported time aggregate values:</h3>
    <h4 style="margin:0px;color:blue">Export Time Threshold: {}ms, Retrieve events: {}</h4>
    <div style="margin:0px">Average = (Retrieved exported time of device events) / (Retrieve events) </div>
    <table style="border: 1px solid black;white-space: initial;"> 
        <tr style="border: 1px solid black;">
            <th style="border: 1px solid black;">
                Device name
            </th>
            <th style="border: 1px solid black;">
                Maximum time	 	 
            </th>
            <th style="border: 1px solid black;">
                Minimum time
            </th>
            <th style="border: 1px solid black;">
                Average time
            </th>
        </tr>
    """.format(SettingsInfo().profile_constant.EXPORT_TIME_THRESHOLD,
               SettingsInfo().profile_constant.EXPORTED_LOOP_TIMES)

    for device in devices:
        html = html + """ 
        <tr style="border: 1px solid black;">
            <td style="border: 1px solid black;">
                {}
            </td>
            <td style="border: 1px solid black;">
                {} ms
            </td>
            <td style="border: 1px solid black;">
                {} ms
            </td>
            <td style="border: 1px solid black;">
                {} ms
            </td>
        </tr> 
        """.format(device, devices_aggregate_list[device]["max"], devices_aggregate_list[device]["min"],
                   devices_aggregate_list[device]["avg"])

    html = html + "</table>"
    logger.info(html, html=True)
    return html

def get_device_export_time_aggregate_value(device):
    global events_exported_time_list
    exported_time_list = events_exported_time_list[device]
    aggregate_value = data_utils.calculate_avg_max_min_from_list(exported_time_list)

    return aggregate_value


def get_devices_aggregate_values():
    int_aggregate_values = get_device_export_time_aggregate_value(devices[0])
    bool_aggregate_values = get_device_export_time_aggregate_value(devices[1])
    uint_aggregate_values = get_device_export_time_aggregate_value(devices[2])
    devices_aggregate_values = {devices[0]: int_aggregate_values,
                                devices[1]: bool_aggregate_values,
                                devices[2]: uint_aggregate_values
                                }
    return devices_aggregate_values
