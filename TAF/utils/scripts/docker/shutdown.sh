#!/bin/sh

docker run --rm -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} -v /var/run/docker.sock:/var/run/docker.sock   \
        docker/compose:1.24.0 -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" down -v
