#!/usr/bin/env python3
"""
Origin : https://www.ev3dev.org/docs/tutorials/sending-and-receiving-messages-with-mqtt/
MQTT Subscriber
"""
import paho.mqtt.client as mqtt
import time
import sys
import requests
import json

topic = sys.argv[1]
keyword = sys.argv[2]
port = sys.argv[3]
secure = sys.argv[4]

def get_token():
    file = open('/tmp/edgex/secrets/device-virtual/secrets-token.json')
    data = json.load(file)
    token = data['auth']['client_token']
    file.close()
    return token


def get_secret():
    token = get_token()
    url = 'http://localhost:8200/v1/secret/edgex/device-virtual/message-bus'
    header = {"X-Vault-Token": "{}".format(token)}
    response = requests.get(url, headers=header)
    secret_data = json.loads(response.content.decode("utf-8"))
    user = secret_data['data']['username']
    password = secret_data['data']['password']
    return user, password


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
        if sys.argv[5] == 'single':
            client.disconnect()

if secure == 'true':
    mqtt_user = get_secret()
else:
    mqtt_user = None

client = mqtt.Client()

if secure == 'true':
    client.username_pw_set(mqtt_user[0], mqtt_user[1])

client.connect("localhost", int(port), 60)

client.on_connect = on_connect
client.on_message = on_message

if sys.argv[5] == 'perf':
    client.loop_start()
    time.sleep(180)
    client.loop_stop()
else:
    client.loop_forever()
