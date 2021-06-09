#!/bin/sh

CONF_DIR=/custom-config
SERVICE_NAME=$1
PROFILE_DIR=$2  # default value: ${PROFILE}

# running device service using service default configuration in the res directory
if [ "$PROFILE_DIR" = "service_default" ]; then
  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
         --security-opt label:disable  \
         --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE}/res --env CONF_DIR=${CONF_DIR} \
         ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" up --no-start --no-deps $SERVICE_NAME

  # copy device service default configuration in the res to TAF/config/{service}/res
  docker cp edgex-${SERVICE_NAME}:/res ${WORK_DIR}/TAF/config/${PROFILE}

  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
         --security-opt label:disable  \
         --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE}/res --env CONF_DIR=${CONF_DIR} \
         ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" start $SERVICE_NAME
else
  # running device service using TAF configuration in the TAF/config/{service} directory
  docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
         --security-opt label:disable \
         --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE_DIR} --env CONF_DIR=${CONF_DIR} \
         ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" up -d $SERVICE_NAME
fi
