#!/bin/sh
CONFIG_DIR=/custom-config

docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --security-opt label:disable --env WORK_DIR=${WORK_DIR} --env CONFIG_DIR=${CONFIG_DIR} \
        --env PROFILE=${PROFILE} ${COMPOSE_IMAGE} docker compose \
        -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" rm -s -f -v $*
