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

cp docker-compose-taf-perf-nexus${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose-end-mqtt.yaml

sed -i '/PROFILE_VOLUME_PLACE_HOLDER: {}/d' docker-compose-end-mqtt.yaml
sed -i 's/\CONF_DIR_PLACE_HOLDER/${CONF_DIR}/g' docker-compose-end-mqtt.yaml
sed -i 's/\PROFILE_VOLUME_PLACE_HOLDER/${WORK_DIR}\/TAF\/config\/${PROFILE}/g' docker-compose-end-mqtt.yaml
sed -i 's/\EXPORT_HOST_PLACE_HOLDER/${DOCKER_HOST_IP}/g' docker-compose-end-mqtt.yaml
sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/${MQTT_BROKER_IP}/g' docker-compose-end-mqtt.yaml