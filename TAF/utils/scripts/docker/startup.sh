#!/bin/sh

docker-compose -f "${WORK_DIR}/TAF/utils/scripts/docker/docker-compose.yaml" up -d $*
