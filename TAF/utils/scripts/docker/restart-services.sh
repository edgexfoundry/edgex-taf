#!/bin/sh
CONF_DIR=/custom-config

docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env --env CONF_DIR=${CONF_DIR} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" restart $*

# Waiting for service started
sleep 3
