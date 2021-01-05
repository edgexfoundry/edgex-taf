#!/bin/bash
# Use specified commit or master
USE_SHA1=$1

# security or no security
USE_NO_SECURITY=$2

# x86_64 or arm64
USE_ARM64=$3

PERF=$4

NIGHTLY_BUILD_URL="https://raw.githubusercontent.com/lenny-intel/developer-scripts/taf/releases/nightly-build/compose-files/taf"

COMPOSE_FILE="docker-compose-taf${PERF}-nexus${USE_NO_SECURITY}${USE_ARM64}.yml"
curl -o ${COMPOSE_FILE} "${NIGHTLY_BUILD_URL}/${COMPOSE_FILE}"
