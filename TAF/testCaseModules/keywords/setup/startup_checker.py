"""
 @copyright Copyright (C) 2019 IOTech Ltd

 @license SPDX-License-Identifier: Apache-2.0

 @file startup_checker.py

 @description
    Helper functions to check value range
"""
import http.client
import ssl
import time
import subprocess

from TAF.testCaseModules.keywords.setup import edgex
from TUC.data.SettingsInfo import SettingsInfo


services = {
        "data": {"composeName": "data",
                 "port": SettingsInfo().constant.CORE_DATA_PORT,
                 "pingUrl": "/api/v2/ping"},
        "metadata": {"composeName": "metadata",
                     "port": SettingsInfo().constant.CORE_METADATA_PORT,
                     "pingUrl": "/api/v2/ping"},
        "command": {"composeName": "command",
                    "port": SettingsInfo().constant.CORE_COMMAND_PORT,
                    "pingUrl": "/api/v2/ping"},
        "support-notifications": {"composeName": "notifications",
                                  "port": SettingsInfo().constant.SUPPORT_NOTIFICATION_PORT,
                                  "pingUrl": "/api/v2/ping"},
        "support-scheduler": {"composeName": "scheduler",
                              "port": SettingsInfo().constant.SUPPORT_SCHEDULER_PORT,
                              "pingUrl": "/api/v2/ping"},
        "app-service-http-export": {"composeName": "app-service-http-export",
                                    "port": SettingsInfo().constant.APP_HTTP_EXPORT_PORT,
                                    "pingUrl": "/api/v2/ping"},
        "app-service-mqtt-export": {"composeName": "app-service-mqtt-export",
                                    "port": SettingsInfo().constant.APP_MQTT_EXPORT_PORT,
                                    "pingUrl": "/api/v2/ping"}
    }

httpConnTimeout = 5


def check_services_startup(check_list):
    token = security_startup_check()
    for item in check_list:
        if item in services:
            SettingsInfo().TestLog.info("Check service " + item + " is startup...")
            check_service_startup(services[item], token)


def security_startup_check():
    if SettingsInfo().constant.SECURITY_SERVICE_NEEDED == 'true':
        SettingsInfo().TestLog.info("Check security services ... ")
        token = edgex.access_token("-useradd")
    else:
        token = ''
    return token


def http_client_connection(port):
    if SettingsInfo().constant.SECURITY_SERVICE_NEEDED == 'true' and '/' in str(port):
        kong_port = port.split('/')[0]
        service_name = "/"+port.split('/')[1]
        conn = http.client.HTTPSConnection(host=SettingsInfo().constant.BASE_URL, port=kong_port, timeout=httpConnTimeout,
                                           context=ssl._create_unverified_context())
    else:
        conn = http.client.HTTPConnection(host=SettingsInfo().constant.BASE_URL, port=port, timeout=httpConnTimeout)
        service_name = ''

    return [conn, service_name]


def check_service_startup(d, token):
    recheck_times = int(SettingsInfo().constant.SERVICE_STARTUP_RECHECK_TIMES)
    wait_time = int(SettingsInfo().constant.SERVICE_STARTUP_WAIT_TIME)
    for i in range(recheck_times):
        SettingsInfo().TestLog.info(
            "Ping service with port {} and request url {} {} ... ".format(str(d["port"]),SettingsInfo().constant.BASE_URL, d["pingUrl"]))
        http_connection = http_client_connection(d["port"])
        conn = http_connection[0]
        service_name = http_connection[1]
        conn.request(method="GET", url="{}{}".format(service_name, d["pingUrl"]),
                     headers={"Authorization": "Bearer {}".format(token)})
        try:
            r1 = conn.getresponse()
        except:
            time.sleep(wait_time)
            continue

        SettingsInfo().TestLog.info(r1.status)
        if int(r1.status) == 200:
            SettingsInfo().TestLog.info("Service is startup.")
            return True
        else:
            time.sleep(wait_time)
            continue
    raise Exception("Start {} failed.".format(d["composeName"]))


def check_service_is_available(port, ping_url):
    recheck_times = int(SettingsInfo().constant.SERVICE_STARTUP_RECHECK_TIMES)
    wait_time = int(SettingsInfo().constant.SERVICE_STARTUP_WAIT_TIME)
    token = security_startup_check()
    for i in range(recheck_times):
        SettingsInfo().TestLog.info(
            "Ping service is available with port {} and request url {} {} ... ".format(port, SettingsInfo().constant.BASE_URL, ping_url))
        http_connection = http_client_connection(port)
        conn = http_connection[0]
        service_name = http_connection[1]
        try:
            conn.request(method="GET", url="{}{}".format(service_name, ping_url),
                         headers={"Authorization": "Bearer {}".format(token)})
            r1 = conn.getresponse()
        except:
            time.sleep(wait_time)
            continue

        SettingsInfo().TestLog.info(r1.status)
        if int(r1.status) == 200:
            SettingsInfo().TestLog.info("Service is startup.")
            return True
        else:
            time.sleep(wait_time)
            continue
    return False


def check_service_startup_by_log(service):
    recheck_times = int(SettingsInfo().constant.SERVICE_STARTUP_RECHECK_TIMES)
    wait_time = int(SettingsInfo().constant.SERVICE_STARTUP_WAIT_TIME)
    if 'modbus' not in service:
        service = "edgex-{}".format(service)

    for i in range(recheck_times):
        SettingsInfo().TestLog.info("Check {} is startup or not.".format(service))
        try:
            logs = subprocess.check_output("docker logs {}".format(service), shell=True)
            keyword = "Service started in:".encode('utf-8')
        except:
            time.sleep(wait_time)
            continue

        if keyword in logs:
            SettingsInfo().TestLog.info("{} is started.".format(service))
            return True
        else:
            SettingsInfo().TestLog.info("Fail to start {}...".format(service))
            time.sleep(wait_time)
            continue
    raise Exception("Start {} failed.".format(service))


def check_service_is_stopped_or_not():
    for i in range(SettingsInfo().profile_constant.RETRY_TIMES):
        logs = subprocess.check_output("docker ps -f name=edgex-", shell=True)
        keyword = "Up ".encode('utf-8')
        if keyword in logs:
            SettingsInfo().TestLog.info("Waiting for all services stop")
            time.sleep(SettingsInfo().profile_constant.WAIT_TIME)
            continue
        else:
            SettingsInfo().TestLog.info("All services are stopped")
            return True
    raise Exception("Not all services are stopped")
