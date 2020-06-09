#!/bin/bash

# # set default values
USE_DB=${1:--redis}
USE_ARCH=${2:--x86_64}
USE_SECURITY=${3:--}
USE_RELEASE=${4:-geneva}

# so wget on windows can pull files
[ "$(uname -o)" = "Msys" ] && WINDOWS_WGET_OPTION="--no-check-certificate"

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64" && ARM64_OPTION="arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty" && NO_SECTY_OPTION="no-secty"

# workaround: no security-enabled redis compose files
[ "$USE_DB" = "-redis" ] && USE_NO_SECURITY="-no-secty"

# # get night-build and geneva compose files
mkdir temp

# Use base compose file from nightly-build for core services
wget ${WINDOWS_WGET_OPTION} -O temp/nb-compose.yaml "https://raw.githubusercontent.com/lenny-intel/developer-scripts/multi2/releases/nightly-build/compose-files/docker-compose-nexus-base.yml"

wget ${WINDOWS_WGET_OPTION} -O temp/geneva-compose.yaml "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/geneva/compose-files/docker-compose-geneva${USE_DB}${USE_NO_SECURITY}${USE_ARM64}.yml"

# replace geneva core services with nightly-build core services
sed -n '/metadata:/,/scheduler:/{//!p;}' temp/nb-compose.yaml > temp/core-services.yaml
sed -n '/Service_Host: edgex-device-virtual/,/edgex-device-modbus:/{//!p;}' docker-compose-device-service.yaml > temp/device-virtual.yaml

sed -n \
    -e '/^version:/,/metadata:/ p' \
    -e '/metadata:/ r temp/core-services.yaml' \
    -e '/scheduler:/,/Service_Host: edgex-device-virtual/ p' \
    -e '/Service_Host: edgex-device-virtual/ r temp/device-virtual.yaml' \
    -e '/ device-rest:/,$ p' \
    temp/geneva-compose.yaml > docker-compose-backward.yaml

# nightly build compose has ARCH variable for the image that geneva doesn't have
if [ "$USE_ARCH" = "arm64" ]; then
  sed -i 's/\${ARCH}/-arm64/g' docker-compose-backward.yaml
else
  sed -i 's/\${ARCH}//g' docker-compose-backward.yaml
fi

rm -rf temp