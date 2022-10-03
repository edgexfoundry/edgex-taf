"""
Subscribe redis channel when using MessageBus.
"""
import redis
import sys
import requests
import json

topic = sys.argv[1]
message = sys.argv[2]
security = sys.argv[3]


def get_token():
    file = open('/tmp/edgex/secrets/device-virtual/secrets-token.json')
    data = json.load(file)
    token = data['auth']['client_token']
    file.close()
    return token


def get_secret():
    token = get_token()
    url = 'http://localhost:8200/v1/secret/edgex/device-virtual/redisdb'
    header = {"X-Vault-Token": "{}".format(token)}
    response = requests.get(url, headers=header)
    secret_data = json.loads(response.content.decode("utf-8"))
    password = secret_data['data']['password']
    return password


if security == 'true':
    pwd = get_secret()
else:
    pwd = None

queue = redis.StrictRedis(host='localhost', port=6379, password=pwd, decode_responses=True)
channel = topic
queue.publish(channel, message)
