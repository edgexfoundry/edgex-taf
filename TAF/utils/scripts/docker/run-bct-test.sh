#!/bin/sh
UN=`uname -m`
case $UN in
  aarch64)
    ARCH=arm64
  ;;
  x86_64)
    ARCH=x86_64
  ;;
  *)
    echo "Unsupported: architecture $UN"
    exit
  ;;
esac

# Arguments and the default values
CASE=${1:-1}
BUS=${2:-redis}

USE_ARCH=${ARCH}
SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED:-false} # This script only supports non-security test
TEST_STRATEGY=${TEST_STRATEGY:-integration-test}

[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# Common Variables
case ${CASE} in
  1)
   CORE_SERVICES_RELEASE=main  # edgex-compose branch or SHA1
   COMPATIBLE_RELEASE=jakarta
   USE_APP=true
   USE_DS=true
  ;;
  2)
   CORE_SERVICES_RELEASE=jakarta  # edgex-compose branch or SHA1
   COMPATIBLE_RELEASE=main
   USE_APP=true
   USE_DS=true
  ;;
  3)
   CORE_SERVICES_RELEASE=main  # edgex-compose branch or SHA1
   COMPATIBLE_RELEASE=jakarta
   USE_APP=false
   USE_DS=true
  ;;
  4)
   CORE_SERVICES_RELEASE=main  # edgex-compose branch or SHA1
   COMPATIBLE_RELEASE=jakarta
   USE_APP=true
   USE_DS=false
  ;;
  *)
  echo "error"
  ;;
esac


TAF_COMMON_IMAGE=nexus3.edgexfoundry.org:10003/edgex-taf-common${USE_ARM64}:latest
COMPOSE_IMAGE=docker:20.10.18


if [ "$SECURITY_SERVICE_NEEDED" = true ]; then
        USE_SECURITY=-security-
else
        USE_SECURITY=-
fi

mkdir -p ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex
if [ "$TEST_STRATEGY" = "integration-test" ] && [ "$BUS" = "mqtt" ]; then
    RUN_TAG=mqtt-bus
else
    RUN_TAG=deploy-base-service
fi

cd ${WORK_DIR}/TAF/utils/scripts/docker
sh get-compose-file.sh ${USE_ARCH} ${USE_SECURITY} jakarta ${TEST_STRATEGY}

# Install base service
docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
    -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
    --security-opt label:disable \
    -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
    --exclude Skipped --include ${RUN_TAG} -u deploy.robot -p default
cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/deploy-base-${BUS}.html

docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
    -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${ARCH} --security-opt label:disable \
    -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
    -v /tmp/edgex/secrets:/tmp/edgex/secrets:z -v /var/run/docker.sock:/var/run/docker.sock \
    --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env ${TAF_COMMON_IMAGE} \
    --exclude Skipped --exclude backward-skip --include MessageQueue=${BUS} \
    -u integrationTest -p device-virtual
cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/jakarta-${BUS}.html

docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
    -e CONFIG_DIR=/custom-config --security-opt label:disable -v /var/run/docker.sock:/var/run/docker.sock \
    ${COMPOSE_IMAGE} docker compose -f ${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yml down

# Get Backward Compose file
sh get-compose-file.sh ${USE_ARCH} ${USE_SECURITY} ${CORE_SERVICES_RELEASE} ${TEST_STRATEGY}
sh get-compose-file-backward.sh ${USE_ARCH} ${USE_SECURITY} ${COMPATIBLE_RELEASE} ${USE_APP} ${USE_DS}

docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
    -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
    --security-opt label:disable \
    -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
    --exclude Skipped --include ${RUN_TAG} -u deploy.robot -p default
cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/bct-deploy-base-${BUS}.html

docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
    -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${ARCH} --security-opt label:disable \
    -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
    -v /tmp/edgex/secrets:/tmp/edgex/secrets:z -v /var/run/docker.sock:/var/run/docker.sock \
    --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env ${TAF_COMMON_IMAGE} \
    --exclude Skipped --exclude backward-skip --include MessageQueue=${BUS} \
    -u integrationTest -p device-virtual
cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/backward-test-${BUS}.html

docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
    --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${ARCH} \
    -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
    --exclude Skipped --include shutdown-edgex -u shutdown.robot -p device-virtual
