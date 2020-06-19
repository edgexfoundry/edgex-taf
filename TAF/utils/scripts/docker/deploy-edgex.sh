#!/bin/sh

DS_PROFILE=docker
CONF_DIR=/custom-config
REGISTRY_URL=consul://edgex-core-consul:8500
BACKWARD=${1:-}
DATABASE=${DATABASE:-redis}

if [ "$USE_DB" = "-mongo" ]; then
  DATABASE=mongo
fi

# Deploy security service when security enabled
if [ "$SECURITY_SERVICE_NEEDED" = true ]; then
  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env DS_PROFILE=${DS_PROFILE} --env CONF_DIR=${CONF_DIR} --env REGISTRY_URL=${REGISTRY_URL} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${BACKWARD}.yaml" up -d security-secrets-setup vault

	sleep 20

  docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env DS_PROFILE=${DS_PROFILE} --env CONF_DIR=${CONF_DIR} --env REGISTRY_URL=${REGISTRY_URL} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${BACKWARD}.yaml" up -d vault-worker kong-db

	sleep 10

	docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env DS_PROFILE=${DS_PROFILE} --env CONF_DIR=${CONF_DIR} --env REGISTRY_URL=${REGISTRY_URL} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${BACKWARD}.yaml" up -d kong-migrations

	sleep 10

	docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env DS_PROFILE=${DS_PROFILE} --env CONF_DIR=${CONF_DIR} --env REGISTRY_URL=${REGISTRY_URL} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${BACKWARD}.yaml" up -d kong

	sleep 20

	docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env DS_PROFILE=${DS_PROFILE} --env CONF_DIR=${CONF_DIR} --env REGISTRY_URL=${REGISTRY_URL} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${BACKWARD}.yaml" up -d edgex-proxy
fi

docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} --security-opt label:disable \
        --env DS_PROFILE=${DS_PROFILE} --env CONF_DIR=${CONF_DIR} --env REGISTRY_URL=${REGISTRY_URL} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose${BACKWARD}.yaml" up -d ${DATABASE} consul data metadata command notifications scheduler
sleep 5

