#!/bin/sh
# # set default values
USE_ARCH=${1:-x86_64}
USE_SECURITY=${2:--}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # sync docker-compose file from developer-script repo
./sync-nightly-build.sh master "${USE_NO_SECURITY}" "${USE_ARM64}" "-perf"

cp docker-compose-taf-perf-nexus${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose-mqtt.yaml

sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/edgex-mqtt-broker/g' docker-compose-mqtt.yaml
sed -i 's/\LOGLEVEL: INFO/LOGLEVEL: DEBUG/g' docker-compose-mqtt.yaml
