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

if [ "$USE_SECURITY" = '-security-' ]; then
    NGINX_ROUTE=",device-rest.http:\/\/edgex-device-rest:59986"
    sed -i "/EDGEX_ADD_PROXY_ROUTE: / s/$/${NGINX_ROUTE}/" docker-compose.yml
fi

MQTT_SERVICES='mqtt-broker mqtt-taf-broker app-mqtt-export'
for service in $MQTT_SERVICES; do
    sed -i "/^\ \ ${service}:/,/^  [a-z].*:$/{//!d}; /^\ \ ${service}:/d" docker-compose.yml
done

# # docker-compose-mqtt.yml file is used on Case 5
# # Then sync TAF performance specific docker-compose file from edgex-compose repo and replace the placeholders
#./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf" "-perf"
cp docker-compose-taf-perf${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose-mqtt.yml
sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/tcp:\/\/${MQTT_BROKER_HOSTNAME}:1883/g' docker-compose-mqtt.yml
sed -i 's/\LOGLEVEL: INFO/LOGLEVEL: DEBUG/g' docker-compose-mqtt.yml
