from robot.api import logger
import time
import StartupTimeHandler
from TUC.data.SettingsInfo import SettingsInfo
import data_utils

# all_up_time : record startup time for deploy EdgeX at once
all_up_time = dict()
all_up_time_without_recreate = dict()
max_min_avg = dict()


class ServiceStartupTime(object):

    def start_time_is_recorded(self):
        self.start_time = time.time()
        logger.info("\n --- Start time %s seconds ---" % self.start_time, also_console=True)

    def fetch_services_startup_time(self):
        global all_up_time
        time.sleep(10)
        all_up_time = get_services_startup_time(self.start_time, StartupTimeHandler.services)
        return all_up_time

    def fetch_services_startup_time_without_creating_containers(self):
        global all_up_time_without_recreate
        time.sleep(10)
        all_up_time_without_recreate = get_services_startup_time(self.start_time,
                                                                  StartupTimeHandler.services)
        return all_up_time_without_recreate

    def show_startup_time_with_avg_max_min(self, title, list):
        StartupTimeHandler.show_avg_max_min_in_html(title, list)

    def get_avg_max_min_values(self, list):
        global max_min_avg
        max_min_avg = data_utils.calculate_avg_max_min_from_list(list)
        return max_min_avg

    def startup_time_is_less_than_threshold_setting(self, list):
        compare_startup_time_with_threshold(list)


def find_total_startup_time(result):
    largest_time = 0
    for k in result:
        if largest_time < result[k]["startupTime"]:
            largest_time = result[k]["startupTime"]

    return str(largest_time)


def get_services_startup_time(start_time, containers):
    result = dict()
    for k in containers:
        StartupTimeHandler.fetch_service_startup_time_by_container_name(containers[k], start_time, result)

    total_startup_time = find_total_startup_time(result)
    result["Total startup time"] = {}
    result["Total startup time"]["binaryStartupTime"] = ""
    result["Total startup time"]["startupTime"] = total_startup_time

    logger.info("Result: " + str(result))
    logger.info("total_startup_time: " + str(total_startup_time))

    return result


def compare_startup_time_with_threshold(list):
    for x in list:
        compare_value = int(SettingsInfo().profile_constant.STARTUP_TIME_THRESHOLD)
        if compare_value < x:
            raise Exception("Startup time is longer than {} seconds".format(SettingsInfo().profile_constant.STARTUP_TIME_THRESHOLD))
    return True

