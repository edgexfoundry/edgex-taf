#!/bin/sh
# Arguments and the default values
USE_ARCH=${1:-x86_64}
SECURITY_SERVICE_NEEDED=${2:-false}
TEST_STRATEGY=${3:-functional-test} # option: functional-test, integration-test
TEST_SERVICE=${4:-api}
DEPLOY_SERVICES=${5:-} # no-deployment or empty

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# Common Variables
USE_SHA1=main  # edgex-compose branch or SHA1
TAF_COMMON_IMAGE=iotechsys/dev-testing-edgex-taf-common:4.0.1
COMPOSE_IMAGE=docker:29.5.2


if [ "$SECURITY_SERVICE_NEEDED" = true ]; then
        USE_SECURITY=-security-
else
        USE_SECURITY=-
fi

# # test delayed start function
if [ "$TEST_SERVICE" = "delayedStart" ]; then
        DELAYED_START=true
else
        DELAYED_START=false
fi

if [ "$DEPLOY_SERVICES" != "no-deployment" ]; then
  echo "Run Deployment With parameters. Strategy: $TEST_STRATEGY, delayedStart: $DELAYED_START"
  # Get compose file from edgex-compose
  sh get-compose-file.sh ${USE_ARCH} ${USE_SECURITY} ${USE_SHA1} ${TEST_STRATEGY} ${DELAYED_START}

  # Create backup report directory
  mkdir -p ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex

  # Install base service
  docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
          -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
          --security-opt label:disable -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
          --exclude Skipped --include deploy-base-service -t deploy.robot -cd default --name deploy -o deploy-edgex
  echo "Waiting for edgex-device-virtual to start..."
  timeout=120
  elapsed=0
  until docker logs edgex-device-virtual 2>&1 | grep -q "Service started in"; do
    sleep 2
    elapsed=$((elapsed + 2))
    if [ "$elapsed" -ge "$timeout" ]; then
      echo "Timeout waiting for edgex-device-virtual to start"
      docker logs edgex-device-virtual
      exit 1
    fi
  done
  echo "edgex-device-virtual started"
fi

case ${TEST_STRATEGY} in
  functional-test)
    # Run functional test
    case ${TEST_SERVICE} in
      device-virtual)
        docker run --rm --network host --name taf-common -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
              --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${USE_ARCH} \
              -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
              -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
              --exclude Skipped -t functionalTest/device-service -cd device-virtual -o device-virtual-common --no-cleanup
      ;;
      device-modbus)
        docker run --rm --network host --name taf-common -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
              --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${USE_ARCH} \
              -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
              -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
              --exclude Skipped -t functionalTest/device-service -cd device-modbus -o device-modbus-common --no-cleanup
      ;;
      api)
        docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
                --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${USE_ARCH} \
                -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
                --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
                -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
                --exclude Skipped -t functionalTest/API -cd default --name API -o api --no-cleanup
      ;;
      *)
        docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
                --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${USE_ARCH} \
                -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
                --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
                -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
                --exclude Skipped -t functionalTest/API/${TEST_SERVICE} -cd default \
                --name API-${TEST_SERVICE} -o api-${TEST_SERVICE} --no-cleanup
      ;;
    esac
  ;;
  integration-test)
    # Run integration test
    ## Only support deploying edgex services through docker-compose file.
    case ${TEST_SERVICE} in
      delayedStart)
        docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
           --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${USE_ARCH} \
           -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
           -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/edgex/secrets:/tmp/edgex/secrets:z \
           --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env ${TAF_COMMON_IMAGE} \
           --include DelayedStart -t integrationTest -cd device-virtual --name delayed-start-test \
           -o delayed-start --no-cleanup
      ;;
      *)
        docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
            --security-opt label:disable -e COMPOSE_IMAGE=${COMPOSE_IMAGE} -e ARCH=${USE_ARCH} \
            -e SECURITY_SERVICE_NEEDED=${SECURITY_SERVICE_NEEDED} \
            --env-file ${WORK_DIR}/TAF/utils/scripts/docker/common-taf.env \
            -v /tmp/edgex/secrets:/tmp/edgex/secrets:z \
            -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
            --exclude Skipped -t integrationTest -cd device-virtual --name integrationTest \
            -o integrationTest --no-cleanup
      ;;
    esac
  ;;
esac

if [ "$DEPLOY_SERVICES" != "no-deployment" ]; then
  # Shutdown
  docker run --rm --network host -v ${WORK_DIR}:${WORK_DIR}:z -w ${WORK_DIR} \
          -e COMPOSE_IMAGE=${COMPOSE_IMAGE} --security-opt label:disable \
          -v /var/run/docker.sock:/var/run/docker.sock ${TAF_COMMON_IMAGE} \
          --exclude Skipped --include shutdown-edgex -t shutdown.robot -cd default \
          --name shutdown -o shutdown --no-cleanup
fi
