#!/usr/bin/env python3
"""
Origin : https://www.ev3dev.org/docs/tutorials/sending-and-receiving-messages-with-mqtt/
"""
import paho.mqtt.client as mqtt


# This is the Subscriber

def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT with result code " + str(rc))
    client.subscribe("edgex-events")


def on_message(client, userdata, msg):
    print(msg.payload.decode())
    if "origin" in msg.payload.decode():
        print("Got mqtt export data!!")
        client.disconnect()


client = mqtt.Client()
client.connect("localhost", 1883, 60)

client.on_connect = on_connect
client.on_message = on_message

client.loop_forever()
