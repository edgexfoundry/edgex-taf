#!/bin/bash

# # set default values
USE_DB=${1:--redis}
USE_ARCH=${2:--x86_64}
USE_SECURITY=${3:--}
USE_RELEASE=${4:-nightly-build}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64" && ARM64_OPTION="arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty" && NO_SECTY_OPTION="no-secty"

# # nightly or other release
mkdir temp
if [ "$USE_RELEASE" = "nightly-build" ]; then
  # generate single file docker-compose.yml for target configuration without
  # default device services, i.e. no device-virtual service
  ./sync-nightly-build.sh temp/docker-compose-temp.yaml no-ds ${ARM64_OPTION} ${NO_SECTY_OPTION}

  # Insert device services into the compose file
  sed -e '/app-service-rules:/r docker-compose-device-service.yaml' -e //N temp/docker-compose-temp.yaml > temp/device-service-temp.yaml

  # Insert required services for end to end tests
  sed -e '/app-service-rules:/r docker-compose-end-to-end.yaml' -e //N temp/device-service-temp.yaml > docker-compose.yaml

else
  COMPOSE_FILE="docker-compose-${USE_RELEASE}${USE_DB}${USE_NO_SECURITY}${USE_ARM64}.yml"
  wget -O ${COMPOSE_FILE} "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/${USE_RELEASE}/compose-files/${COMPOSE_FILE}"

  cp ${COMPOSE_FILE} temp/docker-compose-temp.yaml

  sed -n '/Service_Host: edgex-device-virtual/,/edgex-device-modbus:/{//!p;}' docker-compose-device-service.yaml > temp/device-virtual.yaml

  sed -n \
    -e '1,/Service_Host: edgex-device-virtual/ p' \
    -e '/Service_Host: edgex-device-virtual/ r temp/device-virtual.yaml' \
    -e '/# device-random:/,$ p' \
    temp/docker-compose-temp.yaml > docker-compose.yaml
fi
rm -rf temp
