#!/bin/sh

SERVICE=${1:-}
TIMESTAMP=${2:-}

docker logs edgex-${SERVICE} --since ${TIMESTAMP}
