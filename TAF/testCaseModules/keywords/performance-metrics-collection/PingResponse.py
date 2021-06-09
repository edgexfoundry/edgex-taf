import requests
import requests.packages.urllib3
from robot.api import logger
import data_utils
from TUC.data.SettingsInfo import SettingsInfo

global ping_res_result
ping_res_result = {}


class PingResponse(object):

    def record_response(self, service, res):
        ping_res_result[service] = res
        logger.info("ping_res_result: {}".format(ping_res_result))

    def ping_api_request(self, port, token):
        response = send_ping_request(port, token)
        return response

    def show_the_aggregation_report(self):
        show_aggregation_table_in_html()

    def show_full_response_time_report(self):
        show_the_summary_table_in_html()


def send_ping_request(port, token):
    if "8443" not in str(port):
        service_url = "http://{}:{}".format(SettingsInfo().constant.BASE_URL, port)
    else:
        service_url = "{}://{}:{}".format(SettingsInfo().constant.URI_SCHEME, SettingsInfo().constant.BASE_URL, port)
        requests.packages.urllib3.disable_warnings()  # disable ssl-warning
    ping_url = "{}/api/v2/ping".format(service_url)
    header = {"Authorization": "Bearer {}".format(token)}
    res = requests.get(ping_url, headers=header, verify=False)
    logger.info("response body: {}, reponse time: {}".format(res.content, res.elapsed.total_seconds()))
    response = {
                "body": res.content.decode("utf-8"),
                "seconds": res.elapsed.total_seconds()
                }
    return response


def get_services_response_time_aggregation():
    all_services_res_time = []
    for service in ping_res_result:
        res_aggregation = get_service_aggregation_value(ping_res_result[service])
        agg_value = {
            "name": service,
            "max": res_aggregation["max"],
            "min": res_aggregation["min"],
            "avg": res_aggregation["avg"]
        }
        all_services_res_time.append(agg_value)
    return all_services_res_time


def get_service_aggregation_value(ping_res):
    ping_res_time = []
    for index in range(len(ping_res)):
        ping_service_time = ping_res[index]["seconds"] * 1000
        ping_res_time.append(ping_service_time)

    return data_utils.calculate_avg_max_min_from_list(ping_res_time)


def show_the_summary_table_in_html():
    for res in ping_res_result:
        html = """ 
        <h3 style="margin:0px">Ping {} API latency:</h3>
        <table style="border: 1px solid black;white-space: initial;"> 
            <tr style="border: 1px solid black;">
                <th style="border: 1px solid black;">
                    Index
                </th>
                <th style="border: 1px solid black;">
                    response body
                </th>
                <th style="border: 1px solid black;">
                    response time
                </th>
            </tr>
        """.format(res)

        for index in range(len(ping_res_result[res])):
            html = html + """ 
            <tr style="border: 1px solid black;">
                <td style="border: 1px solid black;">
                    {}			 	 
                </td>
                <td style="border: 1px solid black;">
                    {}
                </td>
                <td style="border: 1px solid black;">
                    {} ms
                </td>
            </tr>
        """.format(
                index, ping_res_result[res][index]["body"],
                float(ping_res_result[res][index]["seconds"]) * 1000
            )

        html = html + "</table>"
        logger.info(html, html=True)


def show_aggregation_table_in_html():
    results = get_services_response_time_aggregation()
    html = """ 
    <h3 style="margin:0px">Ping service response time aggregation:</h3>
    <h4 style="margin:0px;color:blue">Ping Response Time Threshold: {}ms / Retrieve Times: {}
        </h4>
    <table style="border: 1px solid black;white-space: initial;"> 
        <tr style="border: 1px solid black;">
            <th style="border: 1px solid black;">
                Micro service			 	 
            </th>
            <th style="border: 1px solid black;">
                Maximum
            </th>
            <th style="border: 1px solid black;">
                Minimum
            </th>
            <th style="border: 1px solid black;">
                Average
            </th>
        </tr>
    """.format(SettingsInfo().profile_constant.PING_RES_THRESHOLD,
               SettingsInfo().profile_constant.PING_RES_LOOP_TIMES)

    for res in results:
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
    """.format(
            res["name"], res["max"], res["min"], res["avg"]
        )

    html = html + "</table>"
    logger.info(html, html=True)
    return html
