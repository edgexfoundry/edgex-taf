#!/bin/sh
# set default values
USE_ARCH=${1:-x86_64}
USE_SECURITY=${2:--}

# Pull edgex images
sh pull-images.sh ${USE_ARCH} ${USE_SECURITY}

# Run scripts to collect performance metrics and generate reports
docker run --rm --network host --privileged -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} -e ARCH=${USE_ARCH} \
       -v /var/run/docker.sock:/var/run/docker.sock -e COMPOSE_IMAGE=${COMPOSE_IMAGE} ${TAF_COMMON_IMAGE} \
       --exclude Skipped -u performanceTest/performance-metrics-collection --profile performance-metrics

