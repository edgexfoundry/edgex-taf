import RetrieveFootprint
import RetrieveResourceUsage
import StartupTimeHandler
import PingResponse
import EventExportedTime
import RetrieveSystemInfo
from robot.api import logger
import os


class PerformanceSummaryReports(object):

    def show_reports(self, startup_with_creating_container, startup_without_creating_container):
        html = """<h2 style="margin:0px">Performance metrics summary report</h2><br>"""

        # Retrieve system info
        if hasattr(RetrieveSystemInfo, 'report_info'):
            html = html + RetrieveSystemInfo.generate_report(RetrieveSystemInfo.report_info)
        else:
            logger.error("Retrieve System Info")

        # Suite: 1_retrieve_footprint
        if hasattr(RetrieveFootprint, 'resource_usage'):
            html = html + RetrieveFootprint.show_the_summary_table_in_html(RetrieveFootprint.resource_usage)
        else:
            logger.error("Retrieve Footprint Fail")

        html = html + """<br>"""
        # Suite: 2_service_startup_time
        if startup_with_creating_container != 'None':
            html = html + StartupTimeHandler.show_avg_max_min_in_html("Startup time aggregations with creating containers",
                                                        startup_with_creating_container)
        else:
            logger.error("Fail to generate startup time with creating container report")

        html = html + """<br>"""
        if startup_without_creating_container != 'None':
            html = html + StartupTimeHandler.show_avg_max_min_in_html("Startup time aggregations without creating containers",
                                                        startup_without_creating_container)
        else:
            logger.error("Fail to generate startup time without creating container report")

        html = html + """<br>"""
        # Suite: 3_resource_usage_with_autoevent
        if hasattr(RetrieveResourceUsage, 'cpu_usage'):
            html = html + RetrieveResourceUsage.show_the_cpu_aggregation_table_in_html(RetrieveResourceUsage.cpu_usage)
        else:
            logger.error("Retrieve CPU Usage Fail")

        html = html + """<br>"""
        if hasattr(RetrieveResourceUsage, 'mem_usage'):
            html = html + RetrieveResourceUsage.show_the_mem_aggregation_table_in_html(RetrieveResourceUsage.mem_usage)
        else:
            logger.error("Retrieve MEM Usage Fail")

        html = html + """<br>"""
        # Suite: 4_ping_response_time
        if hasattr(RetrieveResourceUsage, 'mem_usage'):
            html = html + PingResponse.show_aggregation_table_in_html()
        else:
            logger.error("Retrieve Ping Response Time Fail")

        html = html + """<br>"""
        # Suite: 5_exported_time
        if hasattr(EventExportedTime, 'devices_aggregate_values_list'):
            html = html + EventExportedTime.show_the_aggregation_table_in_html(EventExportedTime.devices_aggregate_values_list)
        else:
            logger.error("Retrieve Event Exported Time Fail")

        report_path = '{}/TAF/testArtifacts/reports/edgex/performance-metrics.html'.format(os.getenv("WORK_DIR"))
        f = open(report_path, "w+")
        f.write(html)
        f.close()
