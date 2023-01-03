#!/bin/sh
CONFIG_DIR=/custom-config
TEST_STRATEGY=${1:-}
APPSERVICE=${2:-}

if [ "$TEST_STRATEGY" = "PerformanceMetrics" ]; then
  docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --env CONFIG_DIR=${CONFIG_DIR} \
        --security-opt label:disable ${COMPOSE_IMAGE} docker compose \
        -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${APPSERVICE}.yml" down -v
else
  docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --env CONFIG_DIR=${CONFIG_DIR} \
        --security-opt label:disable ${COMPOSE_IMAGE} docker compose \
        -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" down -v
fi
