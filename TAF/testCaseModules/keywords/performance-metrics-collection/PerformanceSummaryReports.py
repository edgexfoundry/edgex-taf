import RetrieveFootprint
import RetrieveResourceUsage
import StartupTimeHandler
# import PingResponse
# import EventExportedTime
from robot.api import logger


class PerformanceSummaryReports(object):

    def show_reports(self, startup_with_creating_container, startup_without_creating_container):
        # Suite: 1_retrieve_footprint
        if hasattr(RetrieveFootprint, 'resource_usage'):
            RetrieveFootprint.show_the_summary_table_in_html(RetrieveFootprint.resource_usage)
        else:
            logger.error("Retrieve Footprint Fail")

        # Suite: 2_service_startup_time
        try:
            startup_with_creating_container
        except NameError:
            startup_with_creating_container = None

        if startup_with_creating_container is not None:
            StartupTimeHandler.show_avg_max_min_in_html("Startup time aggregation with creating containers",
                                                        startup_with_creating_container)

        else:
            logger.error("Fail to generate startup time with creating container report")

        try:
            startup_without_creating_container
        except NameError:
            startup_without_creating_container = None

        if startup_without_creating_container is not None:
            StartupTimeHandler.show_avg_max_min_in_html("Startup time aggregation with creating containers",
                                                        startup_without_creating_container)
        else:
            logger.error("Fail to generate startup time without creating container report")

        # Suite: 3_resource_usage_with_autoevent
        if hasattr(RetrieveResourceUsage, 'cpu_usage'):
            RetrieveResourceUsage.show_the_cpu_aggregation_table_in_html(RetrieveResourceUsage.cpu_usage)
        else:
            logger.error("Retrieve CPU Usage Fail")

        if hasattr(RetrieveResourceUsage, 'mem_usage'):
            RetrieveResourceUsage.show_the_mem_aggregation_table_in_html(RetrieveResourceUsage.mem_usage)
        else:
            logger.error("Retrieve MEM Usage Fail")

        # Suite: 4_ping_response_time
        # PingResponse.show_the_summary_table_in_html()

        # Suite: 5_exported_time
        # EventExportedTime.show_the_summary_table_in_html("redis")

