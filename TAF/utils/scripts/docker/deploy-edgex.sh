#!/bin/sh

TEST_STRATEGY=${1:-}
APPSERVICE=${2:-}

if [ "$TEST_STRATEGY" = "PerformanceMetrics" ]; then
  # temporary fix
  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
          --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
          ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${APPSERVICE}.yaml" up -d consul

  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
          --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
          ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${APPSERVICE}.yaml" up -d
  sleep 5
else

  # Deploy security service when security enabled
  if [ "$SECURITY_SERVICE_NEEDED" = true ]; then
    docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
          --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable ${COMPOSE_IMAGE} \
          -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" up -d \
          security-bootstrapper \
          vault \
          secretstore-setup \
          kong-db \
          consul \
          database \
          kong\
          proxy-setup
  fi

  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
          --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable ${COMPOSE_IMAGE} \
          -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" up -d \
          data \
          metadata \
          command \
          notifications \
          scheduler \
          app-service-functional-tests \
          app-service-http-export
fi
