#!/bin/sh
CONFIG_DIR=/custom-config

docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env --env CONFIG_DIR=${CONFIG_DIR} \
        ${COMPOSE_IMAGE} docker compose -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" \
        restart $*

# Waiting for service started
sleep 2
