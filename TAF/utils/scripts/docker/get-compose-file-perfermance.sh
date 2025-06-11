#!/bin/sh
# # set default values
USE_ARCH=${1:-x86_64}
USE_SECURITY=${2:--}
USE_SHA1=${3:-main}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # first sync standard docker-compose file from edgex-compose repo
./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf" "-perf"

# # docker-compose.yml file is used on Case 1-4
cp docker-compose-taf-perf${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose.yml

MQTT_SERVICES='mqtt-taf-broker app-mqtt-export'
for service in $MQTT_SERVICES; do
    sed -i "/^\ \ ${service}:/,/^  [a-z].*:$/{//!d}; /^\ \ ${service}:/d" docker-compose.yml
done

# # docker-compose-mqtt.yml file is used on Case 5
# # Then sync TAF performance specific docker-compose file from edgex-compose repo and replace the placeholders
#./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf" "-perf"
mqtt_compose_name='docker-compose-mqtt'
cp docker-compose-taf-perf${USE_NO_SECURITY}${USE_ARM64}.yml ${mqtt_compose_name}.yml
sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/tcp:\/\/${EXTERNAL_BROKER_HOSTNAME}:1883/g' ${mqtt_compose_name}.yml
sed -i 's/\LOGLEVEL: INFO/LOGLEVEL: DEBUG/g' ${mqtt_compose_name}.yml

mkdir -p tmp
# External MQTT
sed -n "/^\ \ mqtt-taf-broker:/,/^  [a-z].*:$/p" ${mqtt_compose_name}.yml | sed '$d' > tmp/external-mqtt.yml
sed -i "s/mosquitto-no-auth.conf/etc\/mosquitto\/mosquitto.conf/g" tmp/external-mqtt.yml
sed -i '$a\ \ \ \ volumes:' tmp/external-mqtt.yml
sed -i '/\ \ \ \ volumes:/a \ \ \ \ \ \ - \/${WORK_DIR}\/TAF\/utils\/scripts\/docker\/mosquitto:\/etc\/mosquitto:z' tmp/external-mqtt.yml
sed -i "/^\ \ mqtt-taf-broker:/,/^  [a-z].*:$/{//!d}; /^\ \ mqtt-taf-broker:/d" ${mqtt_compose_name}.yml
sed -i "/services:/ r tmp/external-mqtt.yml" ${mqtt_compose_name}.yml

# Set External MQTT Auth at mqtt-export of app-service
sed -i '/TRIGGER_EXTERNALMQTT_URL/a \ \ \ \ \ \ TRIGGER_EXTERNALMQTT_AUTHMODE: usernamepassword' ${mqtt_compose_name}.yml
if [ "${USE_SECURITY}" = '-security-' ]; then
  sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_AUTHMODE: usernamepassword' ${mqtt_compose_name}.yml
  sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ SECRETSTORE_SECRETSFILE: \/tmp\/secrets.json' ${mqtt_compose_name}.yml
  sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ SECRETSTORE_DISABLESCRUBSECRETSFILE: true' ${mqtt_compose_name}.yml
  sed -i '/\ \ \ \ volumes:/a \ \ \ \ \ \ - \/${WORK_DIR}\/TAF\/testData\/all-services\/secrets.json:\/tmp\/secrets.json' ${mqtt_compose_name}.yml
else
  sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_AUTHMODE: usernamepassword' ${mqtt_compose_name}.yml
  sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ WRITABLE_INSECURESECRETS_MQTT_SECRETDATA_USERNAME: ${EX_BROKER_USER}' ${mqtt_compose_name}.yml
  sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ WRITABLE_INSECURESECRETS_MQTT_SECRETDATA_PASSWORD: ${EX_BROKER_PASSWD}' ${mqtt_compose_name}.yml
fi
rm -rf tmp
