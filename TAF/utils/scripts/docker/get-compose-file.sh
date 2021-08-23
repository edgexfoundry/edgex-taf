#!/bin/bash

# # set default values
USE_ARCH=${1:--x86_64}
USE_SECURITY=${2:--}
USE_SHA1=${3:-main}
TEST_STRATEGY=${4:-}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # pre-release or other release
mkdir -p temp
# generate single file docker-compose.yml for target configuration without
# default device services, i.e. no device-virtual service
./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf"
cp docker-compose-taf${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose.yml

if [ "${TEST_STRATEGY}" = "integration-test" ]; then
  # sync compose file for mqtt message bus
  ./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf" "" "-mqtt-bus"
  cp docker-compose-taf${USE_NO_SECURITY}-mqtt-bus${USE_ARM64}.yml docker-compose-mqtt-bus.yml
  COMPOSE_FILE="docker-compose docker-compose-mqtt-bus"
else
  COMPOSE_FILE="docker-compose"
fi

for compose in ${COMPOSE_FILE}; do
  for profile in device-virtual device-modbus; do
    sed -n "/ ${profile}:/,/ - PROFILE_VOLUME_PLACE_HOLDER/ p" ${compose}.yml > temp/${profile}.yml  # print device-service
    sed -i 's/\CONF_DIR_PLACE_HOLDER/${CONF_DIR}/g' temp/${profile}.yml
    sed -i "s/\PROFILE_VOLUME_PLACE_HOLDER/\${WORK_DIR}\/TAF\/config\/${profile}/g" temp/${profile}.yml
    sed -i "/ ${profile}:/,/ - PROFILE_VOLUME_PLACE_HOLDER/d" ${compose}.yml
    sed -i "/services:/ r temp/${profile}.yml" ${compose}.yml
  done

  sed -i '/PROFILE_VOLUME_PLACE_HOLDER: {}/d' ${compose}.yml
  sed -i 's/\EXPORT_HOST_PLACE_HOLDER/${DOCKER_HOST_IP}/g' ${compose}.yml
  sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/${MQTT_BROKER_IP}/g' ${compose}.yml
  sed -i 's/\LOGLEVEL: INFO/LOGLEVEL: DEBUG/g' ${compose}.yml
  sed -i '/METRICSMECHANISM/d' ${compose}.yml  # remove METRICSMECHANISM env variable to allow change on Consul
done
rm -rf temp
