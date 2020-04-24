"""
 @copyright Copyright (C) 2019 IOTech Ltd

 @license SPDX-License-Identifier: Apache-2.0

 @file startup_checker.py

 @description
    Helper functions to check value range
"""
import http.client
import time

from TUC.data.SettingsInfo import SettingsInfo

services = {
        "data": {"composeName": "data",
                 "port": SettingsInfo().constant.CORE_DATA_PORT,
                 "pingUrl": "/api/v1/ping"},
        "metadata": {"composeName": "metadata",
                     "port": SettingsInfo().constant.CORE_METADATA_PORT,
                     "pingUrl": "/api/v1/ping"},
        "command": {"composeName": "command",
                    "port": SettingsInfo().constant.CORE_COMMAND_PORT,
                    "pingUrl": "/api/v1/ping"},
        "support-logging": {"composeName": "logging",
                            "port": SettingsInfo().constant.SUPPORT_LOGGING_PORT,
                            "pingUrl": "/api/v1/ping"},
        "support-notifications": {"composeName": "notifications",
                                  "port": SettingsInfo().constant.SUPPORT_NOTIFICATION_PORT,
                                  "pingUrl": "/api/v1/ping"},
        "support-scheduler": {"composeName": "scheduler",
                              "port": SettingsInfo().constant.SUPPORT_SCHEDULER_PORT,
                              "pingUrl": "/api/v1/ping"},
        "support-rulesengine": {"composeName": "rulesengine",
                                "port": SettingsInfo().constant.SUPPORT_RULESENGINE_PORT,
                                "pingUrl": "/api/v1/ping"},
        "app-service-http-export": {"composeName": "app-service-http-export",
                                    "port": SettingsInfo().constant.APP_SERVICE_HTTP_EXPORT_PORT,
                                    "pingUrl": "/api/v1/ping"},
        "app-service-mqtt-export": {"composeName": "app-service-mqtt-export",
                                    "port": SettingsInfo().constant.APP_SERVICE_MQTT_EXPORT_PORT,
                                    "pingUrl": "/api/v1/ping"},
    }

httpConnTimeout = 5


def check_services_startup(check_list):
    for item in check_list:
        if item in services:
            SettingsInfo().TestLog.info("Check service " + item + " is startup...")
            check_service_startup(services[item])


def check_service_startup(d):
    recheck_times = int(SettingsInfo().constant.SERVICE_STARTUP_RECHECK_TIMES)
    wait_time = int(SettingsInfo().constant.SERVICE_STARTUP_WAIT_TIME)
    for i in range(recheck_times):
        SettingsInfo().TestLog.info(
            "Ping service with port {} and request url {} {} ... ".format(str(d["port"]),SettingsInfo().constant.BASE_URL, d["pingUrl"]))
        conn = http.client.HTTPConnection(host=SettingsInfo().constant.BASE_URL, port=d["port"], timeout=httpConnTimeout)
        conn.request(method="GET", url=d["pingUrl"])
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
    return False


def check_service_is_available(port, ping_url):
    recheck_times = int(SettingsInfo().constant.SERVICE_STARTUP_RECHECK_TIMES)
    wait_time = int(SettingsInfo().constant.SERVICE_STARTUP_WAIT_TIME)
    for i in range(recheck_times):
        SettingsInfo().TestLog.info(
            "Ping service is available with port {} and request url {} {} ... ".format(port, SettingsInfo().constant.BASE_URL, ping_url))
        conn = http.client.HTTPConnection(host=SettingsInfo().constant.BASE_URL, port=port, timeout=httpConnTimeout)
        try:
            conn.request(method="GET", url=ping_url)
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
