#!/bin/sh

TEST_STRATEGY=${1:-}
APPSERVICE=${2:-}
CONF_DIR=/custom-config

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

  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
          --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
          --env WORK_DIR=${WORK_DIR} --env CONF_DIR=${CONF_DIR} --security-opt label:disable ${COMPOSE_IMAGE} \
          -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" up -d
  sleep 10
fi
