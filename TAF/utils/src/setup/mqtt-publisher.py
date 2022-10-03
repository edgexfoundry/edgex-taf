#!/usr/bin/env python3

import paho.mqtt.client as mqtt
import sys

topic = sys.argv[1]
message = sys.argv[2]
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

if secure == 'true':
    mqtt_user = get_secret()
else:
    mqtt_user = None

client = mqtt.Client()

if secure == 'true':
    client.username_pw_set(mqtt_user[0], mqtt_user[1])

client.connect("localhost", int(port), 60)
client.publish(topic, message)
client.disconnect()
