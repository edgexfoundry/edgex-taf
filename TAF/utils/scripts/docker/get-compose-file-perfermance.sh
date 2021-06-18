#!/bin/sh
# # set default values
USE_ARCH=${1:-x86_64}
USE_SECURITY=${2:--}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # first sync standard docker-compose file from edgex-compose repo
./sync-compose-file.sh master "${USE_NO_SECURITY}" "${USE_ARM64}"

if [ "$USE_SECURITY" != '-security-' ] || [ "$USE_ARCH" = "arm64" ]; then
  cp docker-compose${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose.yml
fi

if [ "$USE_SECURITY" = '-security-' ]; then
    sed -i "/ROUTES_RULES_ENGINE_HOST/a \ \ \ \ \ \ ADD_PROXY_ROUTE: 'device-rest.http://device-rest:59986'" \
    docker-compose.yml
fi

# # Then sync TAF performance specific docker-compose file from edgex-compose repo and replace the placeholders
./sync-compose-file.sh master "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf" "-perf"
cp docker-compose-taf-perf${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose-mqtt.yml
sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/edgex-mqtt-broker/g' docker-compose-mqtt.yml
sed -i 's/\LOGLEVEL: INFO/LOGLEVEL: DEBUG/g' docker-compose-mqtt.yml
