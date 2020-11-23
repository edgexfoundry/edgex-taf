#!/bin/sh
# # set default values
USE_ARCH=${1:-x86_64}
USE_SECURITY=${2:--}

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # sync docker-compose file from developer-script repo
./sync-nightly-build.sh master ${USE_NO_SECURITY} ${USE_ARM64}

cp docker-compose-nexus${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose.yaml

# Insert required services for retrieving exported time
sed -e '1,/- edgex-network/d' docker-compose-end-to-end.yaml > docker-compose-end-mqtt.yaml
sed -e '/app-service-rules:/r docker-compose-end-mqtt.yaml' -e //N docker-compose-nexus${USE_NO_SECURITY}${USE_ARM64}.yml > docker-compose-mqtt.yaml
