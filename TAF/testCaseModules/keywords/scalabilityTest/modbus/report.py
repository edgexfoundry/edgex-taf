import datetime
import os

from robot.api import logger


def generate_report(report_info, records):
    logger.info('▶ Generate report', also_console=True)
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
    hours, rem = divmod(report_info.test_spent_time, 3600)
    minutes, seconds = divmod(rem, 60)
    html += """
        <div class='report-info'>
            <div>Logical CPUs: {} core</div><div>Physical CPUs: {} core</div>
            <div>CPU Frequency: {} MHz</div><div>Memory: {} GB</div>
            <div>Final device amount: {}</div>
            <div>Test spent time {}</div>
            <div>Report generated at {}</div>
        </div>
        
    """.format(report_info.logical_cpus, report_info.physical_cpus,
               report_info.cpu_freq, report_info.memory,
               records[len(records)-1].device_amount,
               '{:0>2}:{:0>2}:{:05.2f}'.format(int(hours), int(minutes), seconds),
               datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S (UTC)"))

    # Records
    html += "<div class='custom-report'><table>"
    html += """
        <thead>
            <th>Case No.</th><th>Device Amount</th>
            <th>CPU</th><th>Memory</th>
            <th>Actual / Expected Accumulated Events</th>
        </thead>
    """

    for r in records:
        html += """ 
            <tr>
                <td rowspan="2">{}</td><td rowspan="2">{}</td>
                <td>{} %</td><td>{} %</td>
                <td rowspan="2">{} / {}</td>
            </tr>
            <tr>
                <td>{} %</td><td>{} %</td>
            </tr>
        """.format(
            r.case_no, r.device_amount,
            r.cpu1, r.mem1,
            r.accumulated_event_amount2, r.expected_accumulated_event_amount2,
            r.cpu2, r.mem2,

        )

    html += "</table></div>"

    logger.info(html, html=True)

    report_path = '{}/TAF/testArtifacts/reports/edgex/modbus-scalability-test.html'.format(os.getenv("WORK_DIR"))
    f = open(report_path, "w+")
    f.write(html)
    f.close()

    # d = dict([
    #     (x.case_no, {'device_amount': x.device_amount, 'cpu1': x.cpu1, 'mem1': x.mem1, 'cpu2': x.cpu2, 'mem2': x.mem2}) for x in records
    # ])
    # logger.info(d, also_console=True)
