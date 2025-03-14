#!/bin/sh
# set default values
USE_ARCH=${1:-x86_64}
USE_SECURITY=${2:--}
USE_SHA1=${3:-odessa}

# # security or not
[ "$USE_SECURITY" = "-security-" ] && SECURITY_SERVICE_NEEDED="true"

TAF_COMMON_IMAGE=iotechsys/dev-testing-edgex-taf-common:3.1.0
COMPOSE_IMAGE=docker:28.0.1


# Pull EdgeX images
sh get-compose-file-perfermance.sh ${USE_SHA1} ${USE_SECURITY}

# Pull images
docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --security-opt label:disable \
        ${COMPOSE_IMAGE} docker compose -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml" pull
sleep 5

# Run scripts to collect performance metrics and generate reports
docker run --rm --network host --privileged -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} -e ARCH=${USE_ARCH} \
       -v /var/run/docker.sock:/var/run/docker.sock -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
       -v /etc/localtime:/etc/localtime --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
       -e COMPOSE_IMAGE=${COMPOSE_IMAGE} ${TAF_COMMON_IMAGE} \
       --exclude Skipped -u performanceTest/performance-metrics-collection --profile performance-metrics

