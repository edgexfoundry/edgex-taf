#!/bin/bash

# # set default values
USE_DB=${1:--redis}
USE_ARCH=${2:--x86_64}
USE_SECURITY=${3:--}
USE_RELEASE=${4:-nightly-build}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # nightly or other release
mkdir temp
if [ "$USE_RELEASE" = "nightly-build" ]; then
     COMPOSE_FILE="docker-compose-nexus${USE_DB}${USE_NO_SECURITY}${USE_ARM64}.yml"
     wget -O ${COMPOSE_FILE} "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/nightly-build/compose-files/${COMPOSE_FILE}"

     cp ${COMPOSE_FILE} temp/docker-compose-temp.yaml
     # Delete device-virtual service from the compose file
     sed -i -r '/device-virtual:/,/- command/ {/ / d;}' temp/docker-compose-temp.yaml

    # Insert device services into the compose file
    sed -e '/ui:/r docker-compose-device-service.yaml' -e //N temp/docker-compose-temp.yaml > temp/device-service-temp.yaml

    # Insert required services for end to end tests
    sed -e '/ui:/r docker-compose-end-to-end.yaml' -e //N temp/device-service-temp.yaml > docker-compose.yaml

else
     [ "$USE_DB" = "-mongo" ] && USE_DB=""
     COMPOSE_FILE="docker-compose${USE_DB}-${USE_RELEASE}${USE_NO_SECURITY}${USE_ARM64}.yml"
     wget -O ${COMPOSE_FILE} "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/${USE_RELEASE}/compose-files/${COMPOSE_FILE}"


     cp ${COMPOSE_FILE} temp/docker-compose-temp.yaml
     # Use Centos base image instead of Alpine base image for Kong for x86_64 CI
     # due to compatibility issues with Alpine image in CI
     sed -i -r 's/kong:1.3.0$/kong:1.3.0-centos/' temp/docker-compose-temp.yaml
     sed -n '/- edgex-device-virtual/,/edgex-device-modbus:/{//!p;}' docker-compose-device-service.yaml > temp/device-virtual.yaml

     if [ "$USE_RELEASE" = "fuji" ]; then
       sed -i.bak 's/--registry/--registry=consul:\/\/edgex-core-consul:8500/' temp/device-virtual.yaml
       sed -i.bak "s/\${DS_PROFILE}/${USE_RELEASE}/" temp/device-virtual.yaml
     fi

     sed -n \
         -e '1,/- edgex-device-virtual/ p' \
         -e '/- edgex-device-virtual/ r temp/device-virtual.yaml' \
         -e '/# device-random:/,$ p' \
         temp/docker-compose-temp.yaml > docker-compose.yaml
fi
rm -rf temp
