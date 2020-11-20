#!/bin/bash

# # set default values
USE_DB=${1:--redis}
USE_ARCH=${2:--x86_64}
USE_SECURITY=${3:--}
USE_RELEASE=${4:-hanoi}
USE_SHA1=${5:-master}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # nightly or other release
mkdir temp
if [ "$USE_RELEASE" = "hanoi" ]; then
  # generate single file docker-compose.yml for target configuration without
  # default device services, i.e. no device-virtual service
  ./sync-nightly-build.sh ${USE_SHA1} ${USE_NO_SECURITY} ${USE_ARM64}

  # Need to remove the existing device services so the added ones below don't conflict
  sed '/  device-rest:/,/- 127.0.0.1:49990:49990\/tcp/d' docker-compose-${USE_RELEASE}${USE_NO_SECURITY}${USE_ARM64}.yml > temp/docker-compose-temp.yaml

  # Insert device services into the compose file
  sed -e '/app-service-rules:/r docker-compose-device-service.yaml' -e //N temp/docker-compose-temp.yaml > temp/device-service-temp.yaml

  # Insert required services for end to end tests
  sed -e '/app-service-rules:/r docker-compose-end-to-end.yaml' -e //N temp/device-service-temp.yaml > docker-compose.yaml

  if [ "$USE_SECURITY" = '-security-' ]; then
    # sed command of MacOS is in different syntax
    if [ "$(uname)" = "Darwin" ]; then
      sed -i '' "/hostname: edgex-vault-worker/i \\
      \      ADD_SECRETSTORE_TOKENS: appservice-http-export-secrets
      " docker-compose.yaml
    else
      sed -i "/hostname: edgex-vault-worker/i \\
      \ADD_SECRETSTORE_TOKENS: appservice-http-export-secrets
      " docker-compose.yaml
    fi
  fi

else
  COMPOSE_FILE="docker-compose-${USE_RELEASE}${USE_DB}${USE_NO_SECURITY}${USE_ARM64}.yml"
  curl -o ${COMPOSE_FILE} "https://raw.githubusercontent.com/edgexfoundry/developer-scripts/master/releases/${USE_RELEASE}/compose-files/${COMPOSE_FILE}"

  cp ${COMPOSE_FILE} temp/docker-compose-temp.yaml

  sed -n '/Service_Host: edgex-device-virtual/,/edgex-device-modbus:/{//!p;}' docker-compose-device-service.yaml > temp/device-virtual.yaml

  sed -n \
     -e '1,/Service_Host: edgex-device-virtual/ p' \
     -e '/Service_Host: edgex-device-virtual/ r temp/device-virtual.yaml' \
     -e '/#  device-random:/,$ p' \
     temp/docker-compose-temp.yaml > docker-compose.yaml

  # new compose file uses `database` as the service name, while older compose has `redis` or `mongo` as the service name
  # so need to adjust the names in the older file so deploy works with service `database` as the service name.
  sed -i 's/\  redis:/  database:/g' docker-compose.yaml
  sed -i 's/\- redis/- database/g' docker-compose.yaml
  sed -i 's/\  mongo:/  database:/g' docker-compose.yaml
  sed -i 's/\- mongo/- database/g' docker-compose.yaml
fi

rm -rf temp
