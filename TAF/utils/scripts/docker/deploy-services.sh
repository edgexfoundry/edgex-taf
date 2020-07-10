#!/bin/sh

if [ "$SECURITY_SERVICE_NEEDED" = "true" ]; then
  SECURITY_ENABLED=true
else
  SECURITY_ENABLED=false
fi

# Deploy service
docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env-file ${WORK_DIR}/TAF/utils/scripts/docker/${ARCH}.env --security-opt label:disable \
        --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE} -e SECURITY_ENABLED=${SECURITY_ENABLED} \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" up -d $*
