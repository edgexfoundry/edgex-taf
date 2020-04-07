#!/bin/sh

USE_DB=$1
ARCH=$2
USE_SECURITY=$3

# # default redis DB
USE_DB=${USE_DB:--redis}

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# workaround: no security-enabled redis compose files
[ "$USE_DB" = "-redis" ] && USE_NO_SECURITY="-no-secty"

# # get night-build and fuji compose files
mkdir temp
wget -O temp/nb-compose.yaml "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/nightly-build/compose-files/docker-compose-nexus${USE_DB}${USE_NO_SECURITY}.yml"
# "mongo" is not specified in the fuji compose filenames
[ "$USE_DB" = "-mongo" ] && USE_DB=""
wget -O temp/fuji-compose.yaml "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/fuji/compose-files/docker-compose${USE_DB}-fuji${USE_NO_SECURITY}.yml"

# replace fuji core services with nightly-build core services
sed -n '/x-common-env-variables/,/^volumes:/{//!p;}' temp/nb-compose.yaml > temp/env-variables.yaml
sed -n '/metadata:/,/scheduler:/{//!p;}' temp/nb-compose.yaml > temp/core-services.yaml
sed -n '/- edgex-device-virtual/,/device-random:/{//!p;}' device-service.yaml > temp/device-virtual.yaml
sed -n \
    -e '1,/x-common-env-variables/ p' \
    -e '/x-common-env-variables/ r temp/env-variables.yaml' \
    -e '/^volumes:/,/metadata:/ p' \
    -e '/metadata:/ r temp/core-services.yaml' \
    -e '/scheduler:/,/- edgex-device-virtual/ p' \
    -e '/- edgex-device-virtual/ r temp/device-virtual.yaml' \
    -e '/# device-random:/,$ p' \
    temp/fuji-compose.yaml > docker-compose-backward.yaml

rm -rf temp

