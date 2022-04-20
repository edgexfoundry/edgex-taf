#!/usr/bin/env python3
"""
Origin : https://www.ev3dev.org/docs/tutorials/sending-and-receiving-messages-with-mqtt/
MQTT Subscriber
"""
import paho.mqtt.client as mqtt
import time
import sys

topic = sys.argv[1]
keyword = sys.argv[2]


def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT with result code " + str(rc))
    client.subscribe(topic)


def on_message(client, userdata, msg):
    current_timestamp = int(round(time.time() * 1000))
    print(current_timestamp)
    print(msg.topic)
    print(msg.payload.decode())
    if keyword in msg.payload.decode():
        print("Got mqtt export data!!")
        if sys.argv[3] != 'perf':
            client.disconnect()


client = mqtt.Client()
client.connect("localhost", 1883, 60)

client.on_connect = on_connect
client.on_message = on_message

if sys.argv[3] != 'perf':
    client.loop_forever()
else:
    client.loop_start()
    time.sleep(180)
    client.loop_stop()
