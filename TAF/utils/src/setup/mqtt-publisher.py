#!/usr/bin/env python3

import paho.mqtt.client as mqtt
import sys

topic = sys.argv[1]
message = sys.argv[2]
port = sys.argv[3]

client = mqtt.Client()
client.connect("localhost", int(port), 60)
client.publish(topic, message)
client.disconnect()
