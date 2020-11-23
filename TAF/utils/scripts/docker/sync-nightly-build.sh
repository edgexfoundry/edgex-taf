#!/bin/bash
# Use specified commit or master
USE_SHA1=$1

# security or no security
USE_NO_SECURITY=$2

# x86_64 or arm64
USE_ARM64=$3

NIGHTLY_BUILD_URL="https://raw.githubusercontent.com/edgexfoundry/developer-scripts/${USE_SHA1}/releases/nightly-build/compose-files"

COMPOSE_FILE="docker-compose-nexus${USE_NO_SECURITY}${USE_ARM64}.yml"
curl -o ${COMPOSE_FILE} "${NIGHTLY_BUILD_URL}/${COMPOSE_FILE}"
