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

./sync-nightly-build.sh temp/nb-compose.yaml ${ARM64_OPTION} ${NO_SECTY_OPTION}

wget ${WINDOWS_WGET_OPTION}  -O temp/geneva-compose.yaml "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/geneva/compose-files/docker-compose-geneva${USE_DB}${USE_NO_SECURITY}${USE_ARM64}.yml"


sed -n '/Service_Host: edgex-device-virtual/,/edgex-device-modbus:/{//!p;}' docker-compose-device-service.yaml > temp/device-virtual.yaml

# replace geneva core services with nightly-build core services
sed -i 's/docker-core-metadata-go:1.2.0/docker-core-metadata-go:master/' temp/geneva-compose.yaml
sed -i 's/docker-core-data-go:1.2.0/docker-core-data-go:master/' temp/geneva-compose.yaml
sed -i 's/docker-core-command-go:1.2.0/docker-core-command-go:master/' temp/geneva-compose.yaml

sed -n \
    -e '/^version:/,/metadata:/ p' \
    -e '/scheduler:/,/Service_Host: edgex-device-virtual/ p' \
    -e '/Service_Host: edgex-device-virtual/ r temp/device-virtual.yaml' \
    -e '/# device-random:/,$ p' \
    temp/geneva-compose.yaml > docker-compose-backward.yaml

rm -rf temp

