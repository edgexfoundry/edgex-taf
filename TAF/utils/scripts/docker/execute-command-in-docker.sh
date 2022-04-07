#!/bin/sh

SERVICE=${1:-}
COMMAND=${2:-}

docker exec edgex-${SERVICE} ${COMMAND}
