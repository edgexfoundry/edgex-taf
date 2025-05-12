from robot.api import logger
import time
from datetime import datetime
import pytz
import os
from TUC.data.SettingsInfo import SettingsInfo
import docker
import re


client = docker.from_env()

msgRegex = r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d+(?:Z|[+-]\d{2}:\d{2}) app=\S* \S*=\S* msg=\"Service started in: \d*.\d*[mµ]?s"
startupDatetimeRegex = r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{0,9}"
binaryStartupTimeRegex = r"\d*.\d*[mµ]?s"


services = {
    "core-keeper": {"containerName": "edgex-core-keeper",
                    "msgRegex": msgRegex, "startupDatetimeRegex": startupDatetimeRegex,
                    "binaryStartupTimeRegex": binaryStartupTimeRegex},
    "core-data": {"containerName": "edgex-core-data",
                  "msgRegex": msgRegex, "startupDatetimeRegex": startupDatetimeRegex,
                  "binaryStartupTimeRegex": binaryStartupTimeRegex},
    "core-metadata": {"containerName": "edgex-core-metadata",
                      "msgRegex": msgRegex, "startupDatetimeRegex": startupDatetimeRegex,
                      "binaryStartupTimeRegex": binaryStartupTimeRegex},
    "core-command": {"containerName": "edgex-core-command",
                     "msgRegex": msgRegex, "startupDatetimeRegex": startupDatetimeRegex,
                     "binaryStartupTimeRegex": binaryStartupTimeRegex},
    "support-notifications": {"containerName": "edgex-support-notifications", "msgRegex": msgRegex,
                              "startupDatetimeRegex": startupDatetimeRegex,
                              "binaryStartupTimeRegex": binaryStartupTimeRegex},
    "support-scheduler": {"containerName": "edgex-support-scheduler",
                               "msgRegex": msgRegex, "startupDatetimeRegex": startupDatetimeRegex,
                               "binaryStartupTimeRegex": binaryStartupTimeRegex},
    "app-service": {"containerName": "edgex-app-rules-engine",
                    "msgRegex": msgRegex, "startupDatetimeRegex": startupDatetimeRegex,
                    "binaryStartupTimeRegex": binaryStartupTimeRegex},
    "device-virtual": {"containerName": "edgex-device-virtual",
                       "msgRegex": msgRegex, "startupDatetimeRegex": startupDatetimeRegex,
                       "binaryStartupTimeRegex": binaryStartupTimeRegex},
    "device-rest": {"containerName": "edgex-device-rest",
                    "msgRegex": msgRegex, "startupDatetimeRegex": startupDatetimeRegex,
                    "binaryStartupTimeRegex": binaryStartupTimeRegex},
}


def fetch_service_startup_time_by_container_name(d, start_time, result):
    res = {"startupDateTime": "", "binaryStartupTime": ""}
    retry_times = int(SettingsInfo().config_constant.RETRY_TIMES)
    container_name = d["containerName"]

    result[container_name] = {}

    for i in range(retry_times):
        try:
            container = client.containers.get(container_name)
            msg = container.logs(until=int(time.time()))
            msg = msg.decode('unicode-escape').encode('latin1').decode('utf-8')  # for 'µ'
            res = parse_started_time_by_service(msg, d)

            startup_datetime_timestamp = convert_startup_datetime_to_timestamp(res["startupDateTime"])
            startup_time = startup_datetime_timestamp - start_time

            if startup_time < 0:
                logger.warn(msg)
                raise Exception("invalid startup time " + str(startup_time))

            result[container_name]["startupTime"] = startup_time
            break
        except docker.errors.NotFound as error:
            logger.error(error)
            break
        except Exception as e:
            logger.warn(e.args)
            if i == (retry_times - 1):
                logger.warn("fail to fetch startup time from " + container_name)
                break
            # wait for retry
            logger.warn("Retry to fetch startup time from " + container_name)
            time.sleep(int(SettingsInfo().config_constant.WAIT_TIME))

    result[container_name]["binaryStartupTime"] = res["binaryStartupTime"]


def convert_startup_datetime_to_timestamp(startup_datetime_str):
    startup_datetime_str = startup_datetime_str[:26]  # Python strptime function only supports 6 microseconds (.ffffff).
    datetime_pattern = "%Y-%m-%dT%H:%M:%S.%f"
    if "T" not in startup_datetime_str:
        datetime_pattern = "%Y-%m-%d %H:%M:%S.%f"

    dt = datetime.strptime(startup_datetime_str, datetime_pattern)
    return dt.timestamp()


def parse_started_time_by_service(msg, d):
    logger.info("Parse log from the service: " + d["containerName"], also_console=True)
    response = {"startupDateTime": "", "binaryStartupTime": ""}

    # level=INFO ts=2019-06-18T07:17:18.5245679Z app=edgex-core-data source=main.go:70 msg="Service started in: 120.62ms"
    # level=INFO ts=2025-02-18T15:30:37.376703321+08:00 app=core-keeper source=message.go:58 msg="Service started in: 2.087827259s"
    x = re.findall(d["msgRegex"], str(msg))
    if len(x) == 0:
        raise Exception("startup msg not found")
    started_msg = x[len(x) - 1]

    # 2019-06-18T07:17:18.524567
    x = re.findall(d["startupDatetimeRegex"], started_msg)
    if len(x) == 0:
        raise Exception("startup msg not found")
    startup_date_time = x[len(x) - 1]
    response["startupDateTime"] = startup_date_time

    x = re.findall(d["binaryStartupTimeRegex"], started_msg)
    binary_startup_time = x[len(x) - 1]
    response["binaryStartupTime"] = binary_startup_time

    return response


def show_full_startup_time_report(title, results):
    for res in results:
        html = """ 
        <h3 style="margin:0px">{}</h3>
        <table style="border: 1px solid black;white-space: initial;"> 
            <tr style="border: 1px solid black;">
                <th style="border: 1px solid black;">
                    Micro service
                </th>
                <th style="border: 1px solid black;">
                    Startup time(Binary)
                </th>
                <th style="border: 1px solid black;">
                    Startup time(Container+Binary)
                </th>
            </tr>
        """.format(title)

        for k in res:
            html = html + """ 
            <tr style="border: 1px solid black;">
                <td style="border: 1px solid black;">
                    {}			 	 
                </td>
                <td style="border: 1px solid black;">
                    {}
                </td>
                <td style="border: 1px solid black;">
                    {} seconds
                </td>
            </tr>
        """.format(
                k, res[k]["binaryStartupTime"], str(res[k]["startupTime"])
            )

        html = html + "</table>"
        logger.info(html, html=True)


def show_avg_max_min_in_html(title, aggregation_list):
    html = """ 
        <h3 style="margin:0px">{}</h3>
        <h4 style="margin:0px;color:blue">Startup Time Threshold: {}s / Retrieve Times: {}
        </h4>
        <table style="border: 1px solid black;white-space: initial;"> 
            <tr style="border: 1px solid black;">
                <th style="border: 1px solid black;">
                    Micro service		 	 
                </th>
                <th style="border: 1px solid black;">
                    Binary maximum time			 	 
                </th>
                <th style="border: 1px solid black;">
                    Binary minimum time
                </th>
                <th style="border: 1px solid black;">
                    Binary average time
                </th>
                <th style="border: 1px solid black;">
                    Container maximum time			 	 
                </th>
                <th style="border: 1px solid black;">
                    Container minimum time
                </th>
                <th style="border: 1px solid black;">
                    Container average time
                </th>
            </tr>
        """.format(title, SettingsInfo().config_constant.STARTUP_TIME_THRESHOLD,
                   SettingsInfo().config_constant.STARTUP_TIME_LOOP_TIMES)

    keys = []
    for item in aggregation_list:
        key = list(item.keys())[0]
        keys.append(key)

    i = 0
    for service in keys:
        binary = aggregation_list[i][service]["binaryStartupTime"]
        container = aggregation_list[i][service]["startupTime"]

        html = html + """ 
            <tr style="border: 1px solid black;">
                <td style="border: 1px solid black;">
                    {}
                </td>""".format(service)
        if service == "Total startup time":
            html = html + """<td style="border: 1px solid black;"> </td>"""
            html = html + """<td style="border: 1px solid black;"> </td>"""
            html = html + """<td style="border: 1px solid black;"> </td>"""
        else:
            html = html + """<td style="border: 1px solid black;">{} seconds""".format(binary["max"])
            html = html + """<td style="border: 1px solid black;">{} seconds""".format(binary["min"])
            html = html + """<td style="border: 1px solid black;">{} seconds""".format(binary["avg"])

        html = html + """<td style="border: 1px solid black;">
                    {} seconds
                </td>
                <td style="border: 1px solid black;">
                    {} seconds
                </td>
                <td style="border: 1px solid black;">
                    {} seconds
                </td>
            </tr>
        """.format(container["max"], container["min"], container["avg"])
        i = i+1
    html = html + "</table>"
    logger.info(html, html=True)
    return html
