#!/bin/bash

MACHINE=${1:-}  # values: edgex, simulator, report-server
SECURITY_SERVICE_NEEDED=${2:-true}
USE_SHA1=${USE_SHA1:-odessa}

[ "$SECURITY_SERVICE_NEEDED" = "false" ] && USE_NO_SECURITY="-no-secty"

. "$(dirname "$0")/config.env"

COMPOSE_IMAGE=docker:28.0.1
# Get HOST_DOCKER_GROUP_ID
DOCKER_ID=$(docker run --rm -v /etc/group:/etc/host/group --entrypoint cat \
       ${COMPOSE_IMAGE} /etc/host/group | grep docker)
HOST_DOCKER_GROUP_ID=$(echo $DOCKER_ID | cut -d : -f 3)

run_compose() {
  echo "Run compose command with arguments: $@"

  docker run --rm \
        -v ${HOME}/.docker/config.json:/root/.docker/config.json -v ${PWD}:${PWD} -w ${PWD} \
        -v /var/run/docker.sock:/var/run/docker.sock -e WORK_DIR=${PWD} --security-opt label:disable \
        -e HOST_DOCKER_GROUP_ID=${HOST_DOCKER_GROUP_ID} \
        ${COMPOSE_IMAGE} docker compose  --env-file compose.env -p edgex "$@"
}

if [ "${MACHINE}" = "edgex" ]; then
  set -e

  # Create influx org and bucket
  sh influx_request.sh

  # Download compose file from edgex-compose
  BUILD_URL="https://raw.githubusercontent.com/edgexfoundry"
  curl -o compose_files/docker-compose.yml "${BUILD_URL}/edgex-compose/${USE_SHA1}/docker-compose${USE_NO_SECURITY}.yml"
  sed -i 's/127.0.0.1/0.0.0.0/g' compose_files/docker-compose.yml

  ## Removed unused service from downloaded compose file
  unused_services="core-data device-virtual device-rest app-rules-engine support-notifications support-scheduler rules-engine ui"
  for service in $unused_services; do
    if [ "${service}" = "ui" ]; then  # The ui service is placed as the last service in the compose file
      sed -i "/^\ \ ${service}:/,/^[a-z].*:$/{//!d}; /^\ \ ${service}:/d" compose_files/docker-compose.yml
    else
      sed -i "/^\ \ ${service}:/,/^  [a-z].*:$/{//!d}; /^\ \ ${service}:/d" compose_files/docker-compose.yml
    fi
  done

  # Generate app-service configuration files
  mkdir -p app_dir simulators/devices
  
  curl -o app_conf.yaml "${BUILD_URL}/app-service-configurable/${USE_SHA1}/res/mqtt-export/configuration.yaml"
  # For environment variable override
  echo "" >> app_conf.yaml
  echo "Trigger:" >> app_conf.yaml
  echo "  SubscribeTopics: \"\"" >> app_conf.yaml

  for n in $(seq 1 ${APP_SERVICE_COUNT})
  do
    # Create app-service configuration file
    mkdir -p app_dir/mqtt-export_${n}
    cp app_conf.yaml app_dir/mqtt-export_${n}/configuration.yaml

    # Update compose files for app-service
    cp compose_files/app-compose${USE_NO_SECURITY}.yaml app_dir/mqtt_${n}.yaml
    sed -i "s/SERVICE_NAME/device-modbus/g" app_dir/mqtt_${n}.yaml
    sed -i "s/PROFILE_NAME/device-sim-${n}/g" app_dir/mqtt_${n}.yaml
    sed -i "s/BROKER_ADDRESS/${REPORT_SERVER_IP}:${BROKER_PORT}/g" app_dir/mqtt_${n}.yaml
    sed -i "s/APP_INDEX/${n}/g" app_dir/mqtt_${n}.yaml
    sed -i "/services:/ r app_dir/mqtt_${n}.yaml" compose_files/docker-compose.yml
    if [ "$SECURITY_SERVICE_NEEDED" = "true" ]; then
      TOKEN_LINE=$(grep '^ *EDGEX_ADD_SECRETSTORE_TOKENS:' compose_files/docker-compose-extra.yml)
      case $TOKEN_LINE in
        *"app-mqtt-export_${n}"*)
          true
          ;;
        *)
          sed -i "/EDGEX_ADD_KNOWN_SECRETS/s/$/,postgres[app-mqtt-export_${n}],message-bus[app-mqtt-export_${n}]/" compose_files/docker-compose-extra.yml
          sed -i "/EDGEX_ADD_SECRETSTORE_TOKENS/s/$/,app-mqtt-export_${n}/" compose_files/docker-compose-extra.yml
          ;;
      esac
    fi

    SIMULATOR_PORT=5020  # Define the first simulator default port
    # Generate devices.yaml
    for i in $(seq 1 ${DEVICE_COUNT})
    do
      cat device-template.yaml >> simulators/devices/device-sim-${n}.yaml
      sed -i "s/DEVICE_INDEX/${i}/g" simulators/devices/device-sim-${n}.yaml
      sed -i "s/SIMULATOR_PORT/${SIMULATOR_PORT}/g" simulators/devices/device-sim-${n}.yaml
      # Since port number of simulators is sequence, increase 1 when creating a new app-service profile
      SIMULATOR_PORT=$((SIMULATOR_PORT+1))
    done
    sed -i "s/PROFILE_NAME/device-sim-${n}/g" simulators/devices/device-sim-${n}.yaml
    sed -i "s/SIMULATOR_IP/${SIMULATOR_IP}/g" simulators/devices/device-sim-${n}.yaml
    sed -i '1s/^/deviceList:\n/' simulators/devices/device-sim-${n}.yaml
  done

  # Deploy services
  run_compose -f compose_files/docker-compose.yml -f compose_files/docker-compose-extra${USE_NO_SECURITY}.yml up -d

  # Wait until device-service is ready
  for i in $(seq 1 20);
  do
    echo "Waiting for the device service to be ready. Loop sleep times:${i}"
    result=$(docker logs edgex-device-modbus | grep "Service started in:" | tr -d "\n")

    if [ -z "$result" ]; then
      sleep 3
    else
      echo "device-service is ready."
      python3 generate-report.py &
      echo "********************************************************************************"
      echo "*** Please find the image report and CSV files in the reports directory after ${TIME_NUMBER} ${TIME_UNIT} ***"
      break
    fi
  done

elif [ "${MACHINE}" = "simulator" ]; then
  docker pull iotechsys/modbus-sim:repl-v3.1.0

  run_compose -f compose_files/docker-compose-simulators.yml up -d

elif [ "${MACHINE}" = "report-server" ]; then
  run_compose -f compose_files/docker-compose-export.yml up -d

elif [ "${MACHINE}" = "shutdown" ]; then
  grep_modbus=$(docker ps -a | grep "device-modbus")
  grep_influx=$(docker ps -a | grep "influx")
  grep_sim=$(docker ps -a | grep "device-sim")

  if [ -n "$grep_modbus" ]; then
    compose_files="-f compose_files/docker-compose.yml -f compose_files/docker-compose-extra${USE_NO_SECURITY}.yml"
  fi
  if [ -n "$grep_influx" ]; then
    compose_files="${compose_files} -f compose_files/docker-compose-export.yml"
  fi
  if [ -n "$grep_sim" ]; then
    compose_files="${compose_files} -f compose_files/docker-compose-simulators.yml"
  fi

  run_compose $compose_files down -v
  rm -rf app_dir simulators/devices
else
  echo "Valid Options: [edgex, simulator, report-server, shutdown]"
fi
