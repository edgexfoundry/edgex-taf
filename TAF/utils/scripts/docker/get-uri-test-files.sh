#!/bin/sh
USE_SECURITY=${1:--}
USE_SHA1=${USE_SHA1:-odessa}
GITHUB_URL="https://raw.githubusercontent.com/edgexfoundry"
UOM_URL="${GITHUB_URL}/edgex-go/${USE_SHA1}/cmd/core-metadata/res"
USE_DB=${USE_DB:-}

. $(dirname "$0")/common-taf.env

# Download files to test URI for files
cd ../../../testData/httpd
## Download UOM file
curl -o uom.yaml ${GITHUB_URL}/edgex-go/${USE_SHA1}/cmd/core-metadata/res/uom.yaml

## Update UoM file
sed -i '$a\ \ \ \ \ \ -\ uritest' uom.yaml

## Download device-onvif-camera files
ONVIF_URL="${GITHUB_URL}/device-onvif-camera/${USE_SHA1}/cmd/res"
curl -o profile.yaml ${ONVIF_URL}/profiles/camera.yaml
curl -o device.yaml ${ONVIF_URL}/devices/camera.yaml.example
curl -o prowatcher.yaml ${ONVIF_URL}/provisionwatchers/generic.provision.watcher.yaml

if [ "${USE_SECURITY}" = "-"  ]; then
  curl -o config.yaml ${ONVIF_URL}/configuration.yaml

  ## Update onvif-camera configuration file
  sed -i "s#./res/profiles#${HTTP_SERVER_DIR}/profile.json#g" config.yaml
  sed -i "s#./res/devices#${HTTP_SERVER_DIR}/device.json#g" config.yaml
  sed -i "s#./res/provisionwatchers#${HTTP_SERVER_DIR}/provisionwatcher.json#g" config.yaml

  # Download common-configuration file
  curl -o common-config.yaml ${GITHUB_URL}/edgex-go/${USE_SHA1}/cmd/core-common-config-bootstrapper/res/configuration.yaml
fi

## Update onvif-camera sample files
sed -i '/labels:/a \ \ -\ \"uritest\"' profile.yaml
sed -i '/description:/ s/$/\ -\ uritest/' device.yaml
sed -i '/serviceName:/a labels:' prowatcher.yaml
sed -i '/labels:/a \ \ -\ uritest' prowatcher.yaml
