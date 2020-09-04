import psutil
import math
import datetime
from robot.api import logger


class ReportInfo:
    def __init__(self, logical_cpus, physical_cpus, cpu_freq, memory):
        self.logical_cpus = logical_cpus
        self.physical_cpus = physical_cpus
        self.cpu_freq = cpu_freq
        self.memory = memory


class RetrieveSystemInfo(object):
    def fetch_system_info(self):
        global report_info
        report_info = fetch_report_info()

    def generate_system_report(self):
        generate_report(report_info)


# fetch_report_info fetches the system information via psutil (https://pypi.org/project/psutil/)
def fetch_report_info():

    logger.info(psutil.cpu_count(), also_console=True)
    logger.info(psutil.cpu_freq(), also_console=True)
    logger.info(psutil.virtual_memory(), also_console=True)

    cpu_freq = 0
    # The cpu_freq is None in some Virtual machine
    if psutil.cpu_freq() is not None:
        cpu_freq = psutil.cpu_freq().max
    report_info = ReportInfo(
        logical_cpus=psutil.cpu_count(),
        physical_cpus=psutil.cpu_count(logical=False),
        cpu_freq=cpu_freq,
        memory=round(psutil.virtual_memory().total / math.pow(2, 30), 1)
    )

    return report_info


def generate_report(report_info):
    html = ""
    # Html css style
    html += """
        <style>
        .message * {
            white-space: initial;
        }
        .custom-report table {
          font-family: arial, sans-serif;
          border-collapse: collapse;
        }

        .custom-report td, .custom-report th {
          border: 1px solid #dddddd;
          text-align: left;
          padding: 8px;
        }

        .report-info > div{
            padding: 10px 0 10px 0;
        } 
        </style>
    """

    # Report info
    html += """
        <div class='report-info'>
            <div>Logical CPUs: {} core</div><div>Physical CPUs: {} core</div>
            <div>CPU Frequency: {} MHz</div><div>Memory: {} GB</div>
            <div>Report generated at {}</div>
        </div>

    """.format(report_info.logical_cpus, report_info.physical_cpus,
               report_info.cpu_freq, report_info.memory,
               datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S (UTC)"))

    logger.info(html, html=True)
    return html
