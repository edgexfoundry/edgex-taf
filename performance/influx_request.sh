#!/bin/bash
# Exit immediately if any command exits with a non-zero status
set -e

. "$(dirname "$0")/config.env"

## Retrieve Org ID
INFLUX_ORG_ID=$(curl -H "Authorization: Token ${INFLUX_INIT_TOKEN}" \
	             -H 'Content-type: application/json' \
                     -s http://${REPORT_SERVER_IP}:8086/api/v2/orgs \
		     | jq -r ".orgs|.[]|.id")

## Post a new auth to get token
RESPONSE=$(curl --request POST \
  http://${REPORT_SERVER_IP}:8086/api/v2/authorizations \
  -H "Authorization: Token ${INFLUX_INIT_TOKEN}" \
  -H 'Content-type: application/json' \
  --data '{
  "status": "active",
  "description": "iot-center-device",
  "orgID": "'"${INFLUX_ORG_ID}"'",
  "permissions": [
    {
      "action": "read",
      "resource": {
        "orgID": "'"${INFLUX_ORG_ID}"'",
        "type": "authorizations"
      }
    },
    {
      "action": "read",
      "resource": {
        "orgID": "'"${INFLUX_ORG_ID}"'",
        "type": "buckets"
      }
    },
    {
      "action": "write",
      "resource": {
        "orgID": "'"${INFLUX_ORG_ID}"'",
        "type": "buckets",
        "name": "iot-center" 
      }
    }
  ]
}')


TOKEN=$(echo $RESPONSE | jq -r '.token')

## Replace Variables in telegraf configuration file
REPORT_SERVER_IN_CONFIG=$(grep -oP 'http://\K([^:/]+)' telegraf.conf)
TOKEN_IN_CONFIG=$(grep -oP 'token = "\K[^"]+' telegraf.conf)
HOST_IN_CONFIG=$(grep -oP 'hostname = "\K[^"]+' telegraf.conf)
sed -i "s/${REPORT_SERVER_IN_CONFIG}/${REPORT_SERVER_IP}/g" telegraf.conf
sed -i "s/${TOKEN_IN_CONFIG}/${TOKEN}/g" telegraf.conf
sed -i "s/${HOST_IN_CONFIG}/${TELEGRAF_HOST}/g" telegraf.conf
