#!/bin/sh
# # set default values
USE_ARCH=${1:--x86_64}
USE_SECURITY=${2:--}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # sync docker-compose file from developer-script repo
./sync-nightly-build.sh ${USE_ARM64} ${USE_NO_SECURITY}

cp docker-compose-nexus${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose.yaml

docker run --rm -v ${WORK_DIR}:${WORK_DIR}:rw,z -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --env WORK_DIR=${WORK_DIR} --security-opt label:disable \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" pull
sleep 5
