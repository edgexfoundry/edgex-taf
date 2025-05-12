#!/bin/sh

TEST_STRATEGY=${1:-}
APPSERVICE=${2:-}
CONFIG_DIR=/custom-config

if [ "$TEST_STRATEGY" = "PerformanceMetrics" ]; then
  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
          --env WORK_DIR=${WORK_DIR} --env PROFILE=${TAF_CONFIG} --security-opt label:disable \
          --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env ${COMPOSE_IMAGE} docker compose \
          -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${APPSERVICE}.yml" up -d
else
  for PROFILE in device-virtual device-modbus device-modbus_1; do
    docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
           --security-opt label:disable --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
           --env CONFIG_DIR=${CONFIG_DIR} --env WORK_DIR=${WORK_DIR} ${COMPOSE_IMAGE} \
           docker compose -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" up --no-start --no-deps ${PROFILE}

    # copy device service default configuration in the res to TAF/config/{service}/res
    docker cp edgex-${PROFILE}:/res/configuration.yaml ${WORK_DIR}/TAF/config/${PROFILE}
    sed -i "s/Device:/Device_old:/" ${WORK_DIR}/TAF/config/${PROFILE}/configuration.yaml
    echo "" >> ${WORK_DIR}/TAF/config/${PROFILE}/configuration.yaml
    echo "Device:" >> ${WORK_DIR}/TAF/config/${PROFILE}/configuration.yaml
    echo "  ProfilesDir: \"$CONFIG_DIR\"" >> ${WORK_DIR}/TAF/config/${PROFILE}/configuration.yaml
    echo "  DevicesDir: \"$CONFIG_DIR\"" >> ${WORK_DIR}/TAF/config/${PROFILE}/configuration.yaml

    ## To set messagebus clientId
    if [ "$PROFILE" = "device-modbus_1" ]; then
      sed -i "s/device-modbus/device-modbus_1/" ${WORK_DIR}/TAF/config/${PROFILE}/configuration.yaml
    fi

  done

  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
          --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
          --add-host=host.docker.internal:host-gateway \
          --env WORK_DIR=${WORK_DIR} --env CONFIG_DIR=${CONFIG_DIR} --security-opt label:disable ${COMPOSE_IMAGE} \
          docker compose -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" up -d
fi

# Waiting for all services startup
sleep 5

if [ "$SECURITY_SERVICE_NEEDED" = "true" ]; then
  for i in $(seq 1 12);
  do
    echo "Waiting for proxy setup is ready. Loop sleep times:${i}"
    result=$(docker logs edgex-proxy-auth | grep "Service started in:")
    if [ -z "$result" ]; then
      sleep 5
    else
      echo "Proxy Setup is ready."
      break
    fi
  done
fi
