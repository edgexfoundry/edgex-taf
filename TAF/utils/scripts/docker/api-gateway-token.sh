#!/bin/sh

option=${1}

if [ "$SECURITY_SERVICE_NEEDED" = true ]; then
    case ${option} in
    -useradd)
    docker run --rm -v ${WORK_DIR}:${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --network=docker_edgex-network --security-opt label:disable \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" \
        run --rm --entrypoint /edgex/security-proxy-setup edgex-proxy --init=false --useradd=testinguser --group=admin \
        | grep '^the access token for'| sed 's/.*: \([^.]*\.[^.]*\.[^.]*\).*/\1/'
    ;;
    -userdel)
    docker run --rm -v ${WORK_DIR}:${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock \
        --network=docker_edgex-network --security-opt label:disable \
        ${COMPOSE_IMAGE} -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" \
        run --rm --entrypoint /edgex/security-proxy-setup edgex-proxy --init=false --userdel=testinguser \
        | grep 'successful to delete' | sed 's/.*"\(.*\)"/\1/'
    ;;
    *)
    exit 0
    ;;
    esac
fi
