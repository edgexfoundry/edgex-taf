#!/usr/bin/env python3
import influxdb_client
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
import pandas as pd
import os, re, sys, time, json
import subprocess
from dotenv import load_dotenv
import util

# To ignore Pivot warning
import warnings
from influxdb_client.client.warnings import MissingPivotFunction

warnings.simplefilter("ignore", MissingPivotFunction)

# Load variables from the config.env file
load_dotenv("config.env")

time_number = os.getenv("TIME_NUMBER")
time_unit = os.getenv("TIME_UNIT")
report_server_ip = os.getenv("REPORT_SERVER_IP")
exclude_service = os.getenv("EXCLUDE_SERVICE")
broker_port = os.getenv("BROKER_PORT")
org = "my-org"
bucket = "my-bucket"
url = f"http://{report_server_ip}:8086"

# Set Report Time Range
time_units = {"minute": "m", "hour": "h", "day": "d"}
calc_units = {"minute": 60, "hour": 3600, "day": 86400}
unit = time_units.get(time_unit)
calc_number = calc_units.get(time_unit)
if not unit:
    print("Invalid time unit. Use 'minute', 'hour', or 'day'.")
    sys.exit(1)

time_range = f"{time_number}{unit}"
duration = int(time_number) * calc_number

# Receive MQTT message and calculate latency and throughput
global event_result
try:
    result = subprocess.run(
        ["python3", "EventReceiver.py", report_server_ip, broker_port, "edgex/events/#", str(duration)],
        check=True,
        capture_output=True,
        text=True
    )
    event_result = result.stdout.replace("Connected to MQTT with result code Success\n", "")
    event_result = event_result.strip().replace("\'", "\"")
except subprocess.CalledProcessError as e:
    print("Error:", e.stderr)


token = util.get_token_from_telegraf_conf("telegraf.conf")

# # Initialize InfluxDB client
client = influxdb_client.InfluxDBClient(url=url, token=token, org=org)


# Retrieve data from influxdb
# Generate Container CPU/Memory Usage DataFrame For LineChart
container_cpu_usage_flux = util.query_flux(bucket, time_range, "docker_container_cpu",
                                      "usage_percent", None, "1m", additional_flux="""
        |> keep(columns: ["container_name", "_value", "_time"])
        |> pivot(rowKey:["_time"], columnKey: ["container_name"], valueColumn: "_value")""")

container_mem_usage_flux = util.query_flux(bucket, time_range, "docker_container_mem",
                                      "usage", None, "1m", additional_flux="""
        |> map(fn:(r) => ({r with _value: r._value / 1024.0 / 1024.0}))
        |> keep(columns: ["container_name", "_value", "_time"])
        |> pivot(rowKey:["_time"], columnKey: ["container_name"], valueColumn: "_value")""")

container_cpu_usage = client.query_api().query_data_frame(container_cpu_usage_flux)
container_mem_usage = client.query_api().query_data_frame(container_mem_usage_flux)
container_cpu_usage.set_index('_time', inplace=True)
container_mem_usage.set_index('_time', inplace=True)


# Generate Container CPU/Memory Aggregation DataFrame Label
# # Retrieve Service List
import subprocess

cmd = "docker ps -a --format {{.Names}}".split()
services = subprocess.run(cmd, capture_output=True, text=True)
services = services.stdout.strip().split('\n')

remove_device_sim = [name for name in services if 'device-sim' not in name]
service_list = [i for i in remove_device_sim if i not in exclude_service]

row = {'aggregation': ['min', 'max', 'avg']}
container_cpu_agg = pd.DataFrame(row)
container_mem_agg = pd.DataFrame(row)

agg_labels = ['min', 'max', 'mean']

# #  Container CPU Aggregation DataFrame
for service in service_list:
    container_cpu_agg_values = []
    for label in agg_labels:
        container_cpu_usage_frame_influx = container_cpu_usage_flux + f"""
        |> {label}(column: "{service}")
        |> keep(columns: ["{service}"])
        |> yield(name: "{label}")
"""
        data = client.query_api().query_data_frame(container_cpu_usage_frame_influx)
        data[service] = data[service].map('{:,.2f}%'.format)
        data.set_index('result', inplace=True)

        container_cpu_agg_values.append(data.loc[label, service])

    container_cpu_agg[service] = container_cpu_agg_values

# # Container Memory Aggregation DataFrame
for service in service_list:
    container_mem_agg_values = []
    for label in agg_labels:
        container_mem_usage_frame_influx = container_mem_usage_flux + f"""
        |> {label}(column: "{service}")
        |> keep(columns: ["{service}"])
        |> yield(name: "{label}")
"""
        data = client.query_api().query_data_frame(container_mem_usage_frame_influx)
        data[service] = data[service].map('{:,.2f}MiB'.format)
        data.set_index('result', inplace=True)

        container_mem_agg_values.append(data.loc[label, service])

    container_mem_agg[service] = container_mem_agg_values

# Create a mapping of original service names to cleaned names
# Remove both "edgex-" and "security-" prefixes
clean_service_list = [service.replace("edgex-", "").replace("security-", "") for service in service_list]
service_name_mapping = {orig: clean for orig, clean in zip(service_list, clean_service_list)}

# # Use the cleaned names for table columns
container_cpu_agg.rename(columns=service_name_mapping, inplace=True)
container_mem_agg.rename(columns=service_name_mapping, inplace=True)

# # Use the cleaned names for line plot labels
container_cpu_usage_clean = container_cpu_usage.rename(columns=service_name_mapping)
container_mem_usage_clean = container_mem_usage.rename(columns=service_name_mapping)

# Generate report chart
fig = plt.figure(figsize=(35, 40), layout='constrained')
fig.text(
    x=.05, y=0.95,
    s='Performance Report',
    ha='left',
    va='bottom',
    weight='bold',
    size=40
)

gs = fig.add_gridspec(5, 4)
ax1 = fig.add_subplot(gs[0, :])  # Container CPU Usage
ax2 = fig.add_subplot(gs[1, :])  # Container CPU Aggregation
ax3 = fig.add_subplot(gs[2, :])  # Container Memory Usage
ax4 = fig.add_subplot(gs[3, :])  # Container Memory Aggregation
ax5_0 = fig.add_subplot(gs[4, :1])  # Latency and Throughput
ax5 = fig.add_subplot(gs[4, 2])  # Latency and Throughput


# # Container CPU Line Chart # #
ax1.set_title('Container CPU Usage', size=25, fontweight="bold")
sns.lineplot(data=container_cpu_usage_clean[list(service_name_mapping.values())], ax=ax1)
sns.move_legend(ax1, "upper left", bbox_to_anchor=(1, 1), title='Service Name')
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))
ax1.set_ylabel('(%)')
ax1.set_xlabel('')
ax1.spines[['right', 'top']].set_visible(False)
# Set
pos0 = ax1.get_position()
pos1 = [pos0.x0, pos0.y0 + 0.1, pos0.width, pos0.height]
ax1.set_position(pos1)

# # Container CPU Aggregation Table # #
ax2.set_title('Container CPU Aggregation', size=25, fontweight="bold")
container_cpu_agg_table = ax2.table(cellText=container_cpu_agg.values, cellLoc='right',
                                    colLabels=container_cpu_agg.columns,
                                    colColours=['lightblue'] * len(container_cpu_agg.columns),
                                    rowLoc='center', colLoc='center', loc='upper center')
container_cpu_agg_table.auto_set_font_size(False)
container_cpu_agg_table.set_fontsize(20)
container_cpu_agg_table.scale(1, 4)
ax2.axis('off')

# # Container Memory Line Chart # #
ax3.set_title('Container Memory Usage', size=25, fontweight="bold")
sns.lineplot(data=container_mem_usage_clean[list(service_name_mapping.values())], ax=ax3)
sns.move_legend(ax3, "upper left", bbox_to_anchor=(1, 1), title='Service Name')
ax3.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))
ax3.set_xlabel('')
ax3.set_ylabel('(MiB)')
ax3.spines[['right', 'top']].set_visible(False)

# # Container Memory Aggregation Table # #
ax4.set_title('Container Memory Aggregation', size=25, fontweight="bold")
container_mem_agg_table = ax4.table(cellText=container_mem_agg.values, cellLoc='right',
                                    colLabels=container_mem_agg.columns,
                                    colColours=['lightblue'] * len(container_mem_agg.columns),
                                    rowLoc='center', colLoc='center', loc='upper center')
container_mem_agg_table.auto_set_font_size(False)
container_mem_agg_table.set_fontsize(20)
container_mem_agg_table.scale(1, 4)
ax4.axis('off')

# # Latency and Throughput
data = json.loads(event_result)
text = f"""Total Event Count: {data["event_count"]}
Total Reading Count: {data["reading_count"]}
Throughput(Total Reading Count / {duration}s): {data["throughput"]}"""

latency = pd.DataFrame.from_dict(data["latency_aggregate"], orient='index', columns=['value (ms)'])
latency.reset_index(inplace=True)
latency.rename(columns={'index': 'aggregation'}, inplace=True)

ax5_0.set_title('Throughput Overview', size=25, fontweight="bold")
ax5_0.text(0.01, 0.9, text, ha='left', va='top', fontsize=30,
           bbox=dict(boxstyle="round", facecolor="wheat", alpha=0.5), transform=ax5_0.transAxes)
ax5_0.axis('off')
ax5.set_title('Latency Aggregation', size=25, fontweight="bold")

latency_table = ax5.table(cellText=latency.values, cellLoc='right',
                          colLabels=latency.columns,
                          colColours=['lightblue'] * len(latency.columns),
                          rowLoc='center', colLoc='center', loc='upper center')
latency_table.auto_set_font_size(False)
latency_table.set_fontsize(20)
latency_table.scale(1, 4)
ax5.axis('off')

# # Layout # #
fig.tight_layout(pad=0.4, w_pad=1.5, h_pad=10)

plt.setp(ax1.get_xticklabels(), rotation=30, horizontalalignment='right')
plt.setp(ax3.get_xticklabels(), rotation=30, horizontalalignment='right')


# Export value of DataFrame to csv file
timestamp = int(time.time())
os.makedirs(f'reports/report-{str(timestamp)}', exist_ok=True)

container_cpu_agg.to_csv(f'reports/report-{str(timestamp)}/container_cpu.csv', index=False)
container_mem_agg.to_csv(f'reports/report-{str(timestamp)}/container_mem.csv', index=False)
latency.to_csv(f'reports/report-{str(timestamp)}/latency.csv', index=False)

filename = f"reports/report-{str(timestamp)}/report.png"

plt.savefig(filename)
print(f"The image report has been saved to {filename}")
