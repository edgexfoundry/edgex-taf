#!/bin/bash

# # set default values
USE_DB=${1:--redis}
USE_ARCH=${2:--x86_64}
USE_SECURITY=${3:--}
USE_RELEASE=${4:-pre-release}
USE_SHA1=${5:-master}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # pre-release or other release
mkdir -p temp
if [ "$USE_RELEASE" = "pre-release" ]; then
  # generate single file docker-compose.yml for target configuration without
  # default device services, i.e. no device-virtual service
  ./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf"
  cp docker-compose-taf${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose.yaml

  for profile in device-virtual device-modbus; do
    sed -n "/ ${profile}:/,/ - PROFILE_VOLUME_PLACE_HOLDER/ p" docker-compose.yaml > temp/${profile}.yml  # print device-service
    sed -i 's/\CONF_DIR_PLACE_HOLDER/${CONF_DIR}/g' temp/${profile}.yml
    sed -i "s/\PROFILE_VOLUME_PLACE_HOLDER/\${WORK_DIR}\/TAF\/config\/${profile}/g" temp/${profile}.yml
    sed -i "/ ${profile}:/,/ - PROFILE_VOLUME_PLACE_HOLDER/d" docker-compose.yaml
    sed -i "/services:/ r temp/${profile}.yml" docker-compose.yaml
  done

  sed -i '/PROFILE_VOLUME_PLACE_HOLDER: {}/d' docker-compose.yaml
  sed -i 's/\EXPORT_HOST_PLACE_HOLDER/${DOCKER_HOST_IP}/g' docker-compose.yaml
  sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/${MQTT_BROKER_IP}/g' docker-compose.yaml
  sed -i 's/\LOGLEVEL: INFO/LOGLEVEL: DEBUG/g' docker-compose.yaml
  sed -i '/METRICSMECHANISM/d' docker-compose.yaml  # remove METRICSMECHANISM env variable to allow change on Consul
else
  COMPOSE_FILE="docker-compose-${USE_RELEASE}${USE_NO_SECURITY}${USE_ARM64}.yml"
  curl -o ${COMPOSE_FILE} "https://raw.githubusercontent.com/edgexfoundry/edgex-compose/${USE_RELEASE}/${COMPOSE_FILE}"
  cp ${COMPOSE_FILE} temp/docker-compose-temp.yaml

  sed -n '/Service_Host: edgex-device-virtual/,/edgex-device-modbus:/{//!p;}' docker-compose-device-service.yaml > temp/device-virtual.yaml

  sed -n \
     -e '1,/Service_Host: edgex-device-virtual/ p' \
     -e '/Service_Host: edgex-device-virtual/ r temp/device-virtual.yaml' \
     -e '/#  device-random:/,$ p' \
     temp/docker-compose-temp.yaml > docker-compose.yaml

  # new compose file uses `database` as the service name, while older compose has `redis` or `mongo` as the service name
  # so need to adjust the names in the older file so deploy works with service `database` as the service name.
  sed -i 's/\  redis:/  database:/g' docker-compose.yaml
  sed -i 's/\- redis/- database/g' docker-compose.yaml
  sed -i 's/\  mongo:/  database:/g' docker-compose.yaml
  sed -i 's/\- mongo/- database/g' docker-compose.yaml
fi

rm -rf temp
