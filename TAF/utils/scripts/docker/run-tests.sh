#!/bin/sh
# Arguments and the default values
TEST_STRATEGY=${1:-functional-test} # option: functional-test, integration-test
SECURITY_SERVICE_NEEDED=${2:-false}
TEST_SERVICE=${3:-api}
DEPLOY_SERVICES=${4:-} # no-deployment or empty

# Common Variables
USE_SHA1=odessa  # edgex-compose branch or SHA1
TAF_COMMON_IMAGE=iotechsys/dev-testing-edgex-taf-common:3.1.0
COMPOSE_IMAGE=docker:28.0.1


if [ "$SECURITY_SERVICE_NEEDED" = true ]; then
        USE_SECURITY=-security-
else
        USE_SECURITY=-
fi

if [ "$DEPLOY_SERVICES" != "no-deployment" ]; then
  # Get compose file from edgex-compose
  sh get-compose-file.sh ${USE_SHA1} ${USE_SECURITY} ${TEST_STRATEGY}

  # Create backup report directory
  mkdir -p ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex

  # Install base service
  docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
          -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
          --security-opt label:disable -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
          --exclude Skipped --include deploy-base-service -u deploy.robot -p default
  cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/deploy-base.html
fi

case ${TEST_STRATEGY} in
  functional-test)
    # Run functional test
    case ${TEST_SERVICE} in
      device-virtual)
        docker run --rm --network host --name taf-common -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
              --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${ARCH} \
              -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
              -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
              --exclude Skipped -u functionalTest/device-service -p device-virtual
        cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/virtual.html
      ;;
      device-modbus)
        docker run --rm --network host --name taf-common -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
              --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${ARCH} \
              -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
              -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
              --exclude Skipped -u functionalTest/device-service -p device-modbus
        cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/modbus.html
      ;;
      api)
        docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
                --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${ARCH} \
                -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
                --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
                -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
                --exclude Skipped -u functionalTest/API -p default
        cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/api-test.html
      ;;
      *)
        docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
                --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${ARCH} \
                -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
                --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
                -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
                --exclude Skipped -u functionalTest/API/${TEST_SERVICE} -p default
        cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/${TEST_SERVICE}-test.html
      ;;
    esac
  ;;
  integration-test)
    # Run integration test
    ## Only support deploying edgex services through docker-compose file.

    docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
            --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${ARCH} \
            -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
            --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
            -v /tmp/edgex/secrets:/tmp/edgex/secrets:z \
            -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
            --exclude Skipped --include MessageBus=${TEST_SERVICE} -u integrationTest -p device-virtual
    cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/integration-test.html
  ;;
  *)
    exit 0
  ;;
esac

if [ "$DEPLOY_SERVICES" != "no-deployment" ]; then
  # Shutdown
  docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
          -e COMPOSE_IMAGE=${COMPOSE_IMAGE} --security-opt label:disable \
          -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
          --exclude Skipped --include shutdown-edgex -u shutdown.robot -p default
  cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/shutdown.html
fi
