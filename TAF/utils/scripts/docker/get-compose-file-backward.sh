#!/bin/bash

# # set default values
USE_DB=${1:--redis}
USE_ARCH=${2:--x86_64}
USE_SECURITY=${3:--}
USE_RELEASE=${4:-geneva}

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# workaround: no security-enabled redis compose files
[ "$USE_DB" = "-redis" ] && USE_NO_SECURITY="-no-secty"

# # get night-build and geneva compose files
mkdir temp
wget -O temp/nb-compose.yaml "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/nightly-build/compose-files/docker-compose-geneva${USE_DB}${USE_NO_SECURITY}.yml"
# "mongo" is not specified in the geneva compose filenames
[ "$USE_DB" = "-mongo" ] && USE_DB=""
wget -O temp/geneva-compose.yaml "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/geneva/docker-compose-geneva${USE_DB}${USE_NO_SECURITY}.yml"

# replace geneva core services with geneva core services
sed -n '/x-common-env-variables/,/^volumes:/{//!p;}' temp/nb-compose.yaml > temp/env-variables.yaml
sed -n '/metadata:/,/scheduler:/{//!p;}' temp/nb-compose.yaml > temp/core-services.yaml
sed -n '/- edgex-device-virtual/,/edgex-device-modbus:/{//!p;}' docker-compose-device-service.yaml > temp/device-virtual.yaml

# Replace the parameter when using geneva device-virtual
if [ "$USE_RELEASE" = "geneva" ]; then
    sed -i.bak 's/--registry/--registry=consul:\/\/edgex-core-consul:8500/' temp/device-virtual.yaml
    sed -i.bak "s/\${DS_PROFILE}/${USE_RELEASE}/" temp/device-virtual.yaml
fi

sed -n \
    -e '1,/x-common-env-variables/ p' \
    -e '/x-common-env-variables/ r temp/env-variables.yaml' \
    -e '/^volumes:/,/metadata:/ p' \
    -e '/metadata:/ r temp/core-services.yaml' \
    -e '/scheduler:/,/- edgex-device-virtual/ p' \
    -e '/- edgex-device-virtual/ r temp/device-virtual.yaml' \
    -e '/# device-random:/,$ p' \
    temp/geneva-compose.yaml > docker-compose-backward.yaml

rm -rf temp

