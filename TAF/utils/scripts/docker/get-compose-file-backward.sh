#!/bin/bash

# # set default values
USE_ARCH=${1:--x86_64}
USE_SECURITY=${2:--}
USE_SHA1=${3:-main}
USE_APP_SERVICE=${4:-true}
USE_DEVICE_SERVICE=${5:-true}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# Retrieve docker-compose file to get app-services and device-services
./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf"
cp docker-compose-taf${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose-${USE_SHA1}.yml

# sync compose file for mqtt message bus
./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf" "" "-mqtt-bus"
cp docker-compose-taf${USE_NO_SECURITY}-mqtt-bus${USE_ARM64}.yml docker-compose-mqtt-bus-${USE_SHA1}.yml

# enable mqtt-broker verbose mode
sed -i '\/usr\/sbin\/mosquitto/ s/$/ -v/' docker-compose-mqtt-bus-${USE_SHA1}.yml

# Set Compose files variable
COMPOSE_FILE="docker-compose docker-compose-mqtt-bus"
COMPOSE_FILE_BCT="docker-compose-${USE_SHA1} docker-compose-mqtt-bus-${USE_SHA1}"


mkdir -p tmp
for compose in ${COMPOSE_FILE_BCT}; do
  for profile in device-virtual device-modbus; do
    sed -n "/ ${profile}:/,/ - PROFILE_VOLUME_PLACE_HOLDER/ p" ${compose}.yml > tmp/${profile}.yml  # print device-service
    sed -i 's/\CONFIG_DIR_PLACE_HOLDER/${CONFIG_DIR}/g' tmp/${profile}.yml
    sed -i "s/\PROFILE_VOLUME_PLACE_HOLDER/\${WORK_DIR}\/TAF\/config\/${profile}/g" tmp/${profile}.yml
    sed -i "/ ${profile}:/,/ - PROFILE_VOLUME_PLACE_HOLDER/d" ${compose}.yml
    sed -i "/services:/ r tmp/${profile}.yml" ${compose}.yml
  done

  # Update services which use DOCKER_HOST_IP
  for service in support-notifications app-http-export; do
    sed -n "/^\ \ ${service}:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/${service}.yml
    sed -i 's/\EXPORT_HOST_PLACE_HOLDER/${DOCKER_HOST_IP}/g' tmp/${service}.yml
    sed -i '$a\ \ \ \ extra_hosts:' tmp/${service}.yml
    sed -i '$a\ \ \ \ -\ \"${DOCKER_HOST_IP}:host-gateway"' tmp/${service}.yml
    sed -i "/^\ \ ${service}:/,/^  [a-z].*:$/{//!d}; /^\ \ ${service}:/d" ${compose}.yml
    sed -i "/services:/ r tmp/${service}.yml" ${compose}.yml
  done

  sed -i '/PROFILE_VOLUME_PLACE_HOLDER: {}/d' ${compose}.yml

  if [ "${USE_SHA1}" = "jakarta" ]; then
    # Supported version:  Ireland, Jakarta, Kamakura
    sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/${EXTERNAL_BROKER_HOSTNAME}/g' ${compose}.yml
  else
    sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/tcp:\/\/${EXTERNAL_BROKER_HOSTNAME}:1883/g' ${compose}.yml
  fi
  sed -i 's/\LOGLEVEL: INFO/LOGLEVEL: DEBUG/g' ${compose}.yml
  sed -i '/METRICSMECHANISM/d' ${compose}.yml  # remove METRICSMECHANISM env variable to allow change on Consul
done

# Define override services
APP_SERVICES='app-external-mqtt-trigger app-functional-tests app-http-export
          app-mqtt-export app-rules-engine app-scalability-test-mqtt-export'
DEVICE_SERVICES='device-virtual device-camera device-modbus device-rest'

if [  "${USE_APP_SERVICE}" = "true" ] && [  "${USE_DEVICE_SERVICE}" = "true" ]; then
  SERVICES="${DEVICE_SERVICES} ${APP_SERVICES}"
elif [  "${USE_APP_SERVICE}" = "true" ] && [  "${USE_DEVICE_SERVICE}" = "false" ]; then
  SERVICES="${APP_SERVICES}"
elif [  "${USE_APP_SERVICE}" = "false" ] && [  "${USE_DEVICE_SERVICE}" = "true" ]; then
  SERVICES="${DEVICE_SERVICES}"
fi

mkdir -p tmp1
for compose in ${COMPOSE_FILE_BCT}; do
  # Set diff filename if compose file contains mqtt string
  case ${compose} in
    *"mqtt"*)
      mqtt="-mqtt"
    ;;
    *)
      mqtt=""
    ;;
  esac

  # Retrieve services from docker-compose-${USE_SHA1}.yml which will be merge to docker-compose.yml
  for service in $SERVICES; do
    sed -n "/^\ \ ${service}:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp1/${service}${mqtt}.yml
  done
done

for compose in ${COMPOSE_FILE}; do
  # Set diff filename if compose file contains mqtt string
  case ${compose} in
    *"mqtt"*)
      mqtt="-mqtt"
    ;;
    *)
      mqtt=""
    ;;
  esac

  # Remove services from docker-compose.yml
  for service in $SERVICES; do
    sed -i "/^\ \ ${service}:/,/^  [a-z].*:$/{//!d}; /^\ \ ${service}:/d" ${compose}.yml
  done

  # Insert service files to docker-compose.yml
  for service in $SERVICES; do
    sed -i "/^services/ r tmp1/${service}${mqtt}.yml" ${compose}.yml
  done
done
rm -rf tmp tmp1
