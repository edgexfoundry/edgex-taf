#!/bin/sh
TEST_STRATEGY=${1:-}
CONF_DIR=/custom-config

if [ "$TEST_STRATEGY" = "PerformanceMetrics" ]; then
  docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env CONF_DIR=${CONF_DIR} ${COMPOSE_IMAGE} \
        -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" \
        restart database consul

  docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env CONF_DIR=${CONF_DIR} ${COMPOSE_IMAGE} \
        -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" \
        restart data metadata command notifications scheduler system \
        device-virtual device-rest app-service-rules
else
  docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env CONF_DIR=${CONF_DIR} ${COMPOSE_IMAGE} \
        -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" restart $*
fi