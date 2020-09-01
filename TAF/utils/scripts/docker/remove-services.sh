#!/bin/sh

CONF_DIR=/custom-config

if [ $1 == "-backward" ]; then
    BACKWARD=$1
    shift
fi

docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env-file ${WORK_DIR}/TAF/utils/scripts/docker/${ARCH}.env --security-opt label:disable \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --env CONF_DIR=${CONF_DIR} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${BACKWARD}.yaml" rm -s -f -v $*
