"""
Subscribe redis channel when using MessageBus.
"""
import redis
import sys
import requests
import json
import time

topic = sys.argv[1]
keyword = sys.argv[2]
security = sys.argv[3]
expected_msg_count = sys.argv[4]
duration = sys.argv[5]
current_msg_count = 0

start_time = time.time()

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
p = queue.pubsub()
p.psubscribe(channel)

while True:
    message = p.get_message()
    if message and not message['type'] == 'psubscribe':
        if keyword in message['channel']:
            current_msg_count += 1
            print(message['channel'])
            print(message['data'])
            if int(expected_msg_count) > 0 and current_msg_count >= int(expected_msg_count):
                # after receiving the expected message number, end the loop
                break
            elif time.time() - start_time >= int(duration):
                # end the loop after the time out
                break
    time.sleep(0.001)
