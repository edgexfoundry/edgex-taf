#!/bin/bash

NIGHTLY_BUILD_URL="https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/nightly-build/compose-files"

# x86_64 or arm64
USE_ARM64=$1

# security or no security
USE_NO_SECURITY=$2

COMPOSE_FILE="docker-compose-nexus${USE_NO_SECURITY}${USE_ARM64}.yml"
curl -o ${COMPOSE_FILE} "${NIGHTLY_BUILD_URL}/${COMPOSE_FILE}"