#!/usr/bin/env python3

import paho.mqtt.client as mqtt
import sys
import time
import math
import json

# Initialize global variables
event_count = 0
reading_count = 0
events_exported_time_list = []


def on_connect(client, userdata, flags, reason_code, properties=None):
    print("Connected to MQTT with result code " + str(reason_code))
    client.subscribe(topic)


def on_message(client, userdata, msg):
    """Callback when a message is received."""
    global event_count, reading_count, events_exported_time_list

    try:
        payload = json.loads(msg.payload.decode())
        current_timestamp = int(round(time.time() * 1000))
        event_count += 1

        event_origin_time = get_origin_time(payload.get("origin", 0))
        readings = payload.get("readings", [])
        reading_count += len(readings)

        export_time = current_timestamp - event_origin_time
        events_exported_time_list.append(export_time)

    except (json.JSONDecodeError, KeyError, TypeError) as e:
        print(f"Error processing message: {e}")


def get_origin_time(origin_time):
    """Normalize origin time to milliseconds."""
    if origin_time > math.pow(10, 18):
        origin_time = int(origin_time / math.pow(10, 6))
    return origin_time


# Get Maximum, Minimum, and Average from list
def calculate_avg_max_min_from_list(list):

    calculate_values = {"max": round(max(list), 2),
                        "min": round(min(list), 2),
                        "avg": round(sum(list) / len(list), 2)}

    return calculate_values


# Validate and parse command-line arguments
if len(sys.argv) != 5:
    print("Usage: script.py <host> <port> <topic> <duration>")
    sys.exit(1)


host = sys.argv[1]
port = int(sys.argv[2])
topic = sys.argv[3]
duration = int(sys.argv[4])

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
client.on_connect = on_connect
client.on_message = on_message

client.connect(host, port, 60)


# Start MQTT loop and wait for the specified duration
client.loop_start()
time.sleep(duration)
client.loop_stop()
client.disconnect()

# Calculate throughput and latency
throughput = round(reading_count / duration, 2)
latency_aggregate = calculate_avg_max_min_from_list(events_exported_time_list)

result_json = {"event_count": event_count, "reading_count": reading_count, "throughput": throughput,
               "latency_aggregate": latency_aggregate}
# Return the results
print(result_json)
