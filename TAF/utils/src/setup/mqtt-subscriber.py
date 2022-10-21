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
expected_msg_count = sys.argv[5]  # if value is -1 means loop with duration
duration = sys.argv[6]
current_msg_count = 0

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
    global current_msg_count
    current_timestamp = int(round(time.time() * 1000))
    if keyword in msg.payload.decode():
        current_msg_count += 1
        print(current_timestamp)
        print(msg.topic)
        print(msg.payload.decode())
        print("Got message!!")
        if int(expected_msg_count) < 0:
            # keep subscribing the message until loop_stop()
            return
        elif current_msg_count >= int(expected_msg_count) :
            client.disconnect()

if secure == 'true':
    mqtt_user = get_secret()
else:
    mqtt_user = None

client = mqtt.Client()

if secure == 'true':
    client.username_pw_set(mqtt_user[0], mqtt_user[1])

client.on_connect = on_connect
client.on_message = on_message
client.connect("localhost", int(port), 60)

if int(expected_msg_count) < 0 :
    client.loop_start()
    time.sleep(int(duration))
    client.disconnect()
    client.loop_stop()
else:
    client.loop_forever()
