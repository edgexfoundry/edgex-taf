#!/bin/bash
# Use specified commit or master
USE_SHA1=$1

# security or no security
USE_NO_SECURITY=$2

# x86_64 or arm64
USE_ARM64=$3

TAF=$4
TAF_PERF=$5
PRE_RELEASE="-pre-release"
# Handle TAF specific compose files
[ "$TAF" = "-taf" ] && TAF_SUB_FOLDER="/taf" && PRE_RELEASE=""

NIGHTLY_BUILD_URL="https://raw.githubusercontent.com/edgexfoundry/edgex-compose/${USE_SHA1}${TAF_SUB_FOLDER}"

COMPOSE_FILE="docker-compose${PRE_RELEASE}${TAF}${TAF_PERF}${USE_NO_SECURITY}${USE_ARM64}.yml"
curl -o ${COMPOSE_FILE} "${NIGHTLY_BUILD_URL}/${COMPOSE_FILE}"
