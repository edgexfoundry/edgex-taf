#!/bin/sh

CONF_DIR=/custom-config
SERVICE_NAME=$1
REGISTRY_URL=$2

docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE}  \
        --env CONF_DIR=${CONF_DIR} --env REGISTRY_URL=${REGISTRY_URL} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" up -d $SERVICE_NAME
