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
        times = SettingsInfo().profile_constant.EXPORTED_LOOP_TIMES
        device_int = []
        device_bool = []
        device_uint = []

        full_subscriber_logs = subprocess.check_output("python ${WORK_DIR}/TAF/utils/src/setup/mqtt-subscriber.py perf",
                                                       shell=True)
        subscriber_logs = full_subscriber_logs.decode("utf-8").replace("Connected to MQTT with result code 0", "")
        events = subscriber_logs.split('Got mqtt export data!!')
        for event in events:
            if "deviceName" in event:
                event_str = event.split('\n')
                event_json = json.loads(event_str[2])
                event_json['received'] = int(event_str[1])

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
        for device in result["devices"]:
            for event in result["devices"][device]:
                event["origin"] = get_origin_time(event["origin"])
                event["exported"] = event["received"] - event["origin"]
                events.append(event)

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
    <div style="margin:0px">Average = (Retrieved exported time of device events - max - min) / (Retrieve events - 2) </div>
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


def get_device_export_time_list(device):
    exported_time_list = []
    for event in result["devices"][device]:
        exported_time_list.append(event["exported"])
    return exported_time_list


def get_device_export_time_aggregate_value(device):
    exported_time_list = get_device_export_time_list(device)

    # Get aggregate value without removing max and min
    org_aggregate_value = data_utils.calculate_avg_max_min_from_list(exported_time_list)
    del org_aggregate_value["avg"]

    # Remove max and min and get average value
    exported_time_list.remove(max(exported_time_list))
    exported_time_list.remove(min(exported_time_list))
    aggregate_value = data_utils.calculate_avg_max_min_from_list(exported_time_list)

    # Update the aggregate value to use the original max and min
    aggregate_value.update(org_aggregate_value)

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
