#!/bin/bash

# # set default values
USE_ARCH=${1:--x86_64}
USE_SECURITY=${2:--}
USE_SHA1=${3:-napa}
TEST_STRATEGY=${4:-}
DELAYED_START=${5:-false}

. $(dirname "$0")/common-taf.env

# # x86_64 or arm64
[ "$USE_ARCH" = "arm64" ] && USE_ARM64="-arm64"

# # security or no security
[ "$USE_SECURITY" != '-security-' ] && USE_NO_SECURITY="-no-secty"

# # pre-release or other release
mkdir -p tmp
# generate single file docker-compose.yml for target configuration without
# default device services, i.e. no device-virtual service
./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf"
cp docker-compose-taf${USE_NO_SECURITY}${USE_ARM64}.yml docker-compose.yml

if [ "${TEST_STRATEGY}" = "integration-test" ]; then
  # sync compose file for mqtt message bus
  ./sync-compose-file.sh "${USE_SHA1}" "${USE_NO_SECURITY}" "${USE_ARM64}" "-taf" "" "-mqtt-bus"
  cp docker-compose-taf${USE_NO_SECURITY}-mqtt-bus${USE_ARM64}.yml docker-compose-mqtt-bus.yml
  # Set Compose files variable
  COMPOSE_FILE="docker-compose docker-compose-mqtt-bus"
else
  COMPOSE_FILE="docker-compose"
fi

for compose in ${COMPOSE_FILE}; do
  for profile in device-virtual device-modbus; do
    sed -n "/^\ \ ${profile}:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/${profile}.yml  # print device-service
    sed -i 's/\CONFIG_DIR_PLACE_HOLDER/${CONFIG_DIR}/g' tmp/${profile}.yml
    sed -i "s/\PROFILE_VOLUME_PLACE_HOLDER/\${WORK_DIR}\/TAF\/config\/${profile}/g" tmp/${profile}.yml

    # Enable Delayed Start
    if [ "${TEST_STRATEGY}" = "integration-test" ] && [ "${USE_SECURITY}" = '-security-' ] \
      && [ "${DELAYED_START}" = 'true' ]; then
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ SECRETSTORE_RUNTIMETOKENPROVIDER_ENABLED: "true"' tmp/${profile}.yml
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ SECRETSTORE_RUNTIMETOKENPROVIDER_HOST: edgex-security-spiffe-token-provider' tmp/${profile}.yml
      sed -i "s/\/tmp\/edgex\/secrets\/${profile}/\/tmp\/edgex\/secrets\/spiffe\/public/g" tmp/${profile}.yml
    fi
    sed -i "/^\ \ ${profile}:/,/^  [a-z].*:$/{//!d}; /^\ \ ${profile}:/d" ${compose}.yml
    sed -i "/services:/ r tmp/${profile}.yml" ${compose}.yml
  done

  # Enable Delayed Start
  if [ "${TEST_STRATEGY}" = "integration-test" ] && [ "${USE_SECURITY}" = '-security-' ] \
        && [ "${DELAYED_START}" = 'true' ]; then
    for service in support-notifications support-scheduler; do
      sed -n "/^\ \ ${service}:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/${service}.yml
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ SECRETSTORE_RUNTIMETOKENPROVIDER_ENABLED: "true"' tmp/${service}.yml
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ SECRETSTORE_RUNTIMETOKENPROVIDER_HOST: edgex-security-spiffe-token-provider' tmp/${service}.yml
      sed -i "s/\/tmp\/edgex\/secrets\/${service}/\/tmp\/edgex\/secrets\/spiffe\/public/g" tmp/${service}.yml
      sed -i "/^\ \ ${service}:/,/^  [a-z].*:$/{//!d}; /^\ \ ${service}:/d" ${compose}.yml
      sed -i "/services:/ r tmp/${service}.yml" ${compose}.yml
    done
  fi

  # Update app-sample PerTopicPipeline
  sed -n '/^\ \ app-sample:/,/^  [a-z].*:$/p' ${compose}.yml | sed '$d' > tmp/app-sample.yml
  sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ WRITABLE_PIPELINE_FUNCTIONS_HTTPEXPORT_PARAMETERS_URL: http:\/\/${DOCKER_HOST_IP}:7770' tmp/app-sample.yml
  sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS: tcp:\/\/${EXTERNAL_BROKER_HOSTNAME}:1883' tmp/app-sample.yml
  sed -i '$a\ \ \ \ extra_hosts:' tmp/app-sample.yml
  sed -i '$a\ \ \ \ -\ \"${DOCKER_HOST_IP}:host-gateway"' tmp/app-sample.yml
  sed -i '/^\ \ app-sample:/,/^  [a-z].*:$/{//!d}; /^\ \ app-sample:/d' ${compose}.yml
  sed -i '/services:/ r tmp/app-sample.yml' ${compose}.yml

  # Enable North-South Messaging
  if [ "${TEST_STRATEGY}" = "integration-test" ]; then
    sed -n "/^\ \ core-command:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/core-command.yml
    sed -i '/EXTERNALMQTT_URL/d' tmp/core-command.yml
    sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ EXTERNALMQTT_ENABLED: true' tmp/core-command.yml
    sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ EXTERNALMQTT_URL: tcp:\/\/${EXTERNAL_BROKER_HOSTNAME}:1883' tmp/core-command.yml
    sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ EXTERNALMQTT_RETAIN: false' tmp/core-command.yml
    sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ EXTERNALMQTT_AUTHMODE: usernamepassword' tmp/core-command.yml
    if [ "${USE_SECURITY}" = '-security-' ]; then
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ SECRETSTORE_SECRETSFILE: \/tmp\/secrets.json' tmp/core-command.yml
      sed -i '/SECRETSTORE_SECRETSFILE/a \ \ \ \ \ \ SECRETSTORE_DISABLESCRUBSECRETSFILE: true' tmp/core-command.yml
    else
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ WRITABLE_INSECURESECRETS_MQTT_SECRETDATA_USERNAME: ${EX_BROKER_USER}' tmp/core-command.yml
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ WRITABLE_INSECURESECRETS_MQTT_SECRETDATA_PASSWORD: ${EX_BROKER_PASSWD}' tmp/core-command.yml
      # Uri for files
      if [ "${compose}" = "docker-compose" ]; then
        sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ DATABASE_HOST: edgex-redis' tmp/core-command.yml
        sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ MESSAGEBUS_HOST: edgex-redis' tmp/core-command.yml
        sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ REGISTRY_HOST: edgex-core-consul' tmp/core-command.yml
        sed -i "/\ \ \ \ environment:/a \ \ \ \ \ \ EDGEX_COMMON_CONFIG: ${HTTP_SERVER_DIR}/common-config.yaml" tmp/core-command.yml
        sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ EDGEX_CONFIG_PROVIDER: none' tmp/core-command.yml
      fi
      ###
    fi
    sed -i "/^\ \ core-command:/,/^  [a-z].*:$/{//!d}; /^\ \ core-command:/d" ${compose}.yml
    sed -i "/services:/ r tmp/core-command.yml" ${compose}.yml
    # External MQTT
    sed -n "/^\ \ mqtt-taf-broker:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/external-mqtt.yml
    sed -i "s/mosquitto-no-auth.conf/etc\/mosquitto\/mosquitto.conf/g" tmp/external-mqtt.yml
    sed -i '$a\ \ \ \ volumes:' tmp/external-mqtt.yml
    sed -i '/\ \ \ \ volumes:/a \ \ \ \ - \/${WORK_DIR}\/TAF\/utils\/scripts\/docker\/mosquitto:\/etc\/mosquitto:z' tmp/external-mqtt.yml
    sed -i "/^\ \ mqtt-taf-broker:/,/^  [a-z].*:$/{//!d}; /^\ \ mqtt-taf-broker:/d" ${compose}.yml
    sed -i "/services:/ r tmp/external-mqtt.yml" ${compose}.yml

    # Set External MQTT Auth at mqtt-export of app-service
    sed -i '/TRIGGER_EXTERNALMQTT_URL/a \ \ \ \ \ \ TRIGGER_EXTERNALMQTT_AUTHMODE: usernamepassword' ${compose}.yml
    if [ "${USE_SECURITY}" = '-security-' ]; then
      sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_AUTHMODE: usernamepassword' ${compose}.yml
      sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ SECRETSTORE_SECRETSFILE: \/tmp\/secrets.json' ${compose}.yml
      sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ SECRETSTORE_DISABLESCRUBSECRETSFILE: true' ${compose}.yml
      sed -i '/\ \ \ \ volumes:/a \ \ \ \ - \/${WORK_DIR}\/TAF\/testData\/all-services\/secrets.json:\/tmp\/secrets.json' ${compose}.yml
    else
      sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_AUTHMODE: usernamepassword' ${compose}.yml
      sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ WRITABLE_INSECURESECRETS_MQTT_SECRETDATA_USERNAME: ${EX_BROKER_USER}' ${compose}.yml
      sed -i '/WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS/a \ \ \ \ \ \ WRITABLE_INSECURESECRETS_MQTT_SECRETDATA_PASSWORD: ${EX_BROKER_PASSWD}' ${compose}.yml
    fi

    # Multiple Instance of device-modbus
    sed -n "/^\ \ device-modbus:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/device-modbus_1.yml
    sed -i 's/device-modbus/device-modbus_1/g' tmp/device-modbus_1.yml
    sed -i "s/device-modbus_1${USE_ARM64}:3.1.0/device-modbus${USE_ARM64}:3.1.0/g" tmp/device-modbus_1.yml
    if [ "${USE_SECURITY}" = '-security-' ]; then
      sed -i 's/- \/device-modbus_1/- \/device-modbus/g' tmp/device-modbus_1.yml
    fi
    sed -i 's/published: \"59901\"/published: "59911"/g' tmp/device-modbus_1.yml
    sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ EDGEX_INSTANCE_NAME: 1' tmp/device-modbus_1.yml
    sed -i "/services:/ r tmp/device-modbus_1.yml" ${compose}.yml

    if [ "${USE_SECURITY}" = '-security-' ]; then
      # Add secrets for device-modbus_1
      sed -i '/EDGEX_ADD_REGISTRY_ACL_ROLES/ s/$/,device-modbus_1/' ${compose}.yml
      sed -i '/EDGEX_ADD_KNOWN_SECRETS/ s/$/,redisdb[device-modbus_1],message-bus[device-modbus_1]/' ${compose}.yml
      sed -i '/EDGEX_ADD_SECRETSTORE_TOKENS/ s/$/,device-modbus_1/' ${compose}.yml

      # Enable CORS Configuration
      sed -n "/^\ \ security-proxy-setup:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/security-proxy-setup.yml
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ EDGEX_SERVICE_CORSCONFIGURATION_ENABLECORS: true' tmp/security-proxy-setup.yml
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ EDGEX_SERVICE_CORSCONFIGURATION_CORSALLOWCREDENTIALS: true' tmp/security-proxy-setup.yml
      sed -i "/^\ \ security-proxy-setup:/,/^  [a-z].*:$/{//!d}; /^\ \ security-proxy-setup:/d" ${compose}.yml
      sed -i "/services:/ r tmp/security-proxy-setup.yml" ${compose}.yml

      # Add proxy route for device-onvif-camera
      sed -i '/EDGEX_ADD_PROXY_ROUTE/ s/$/,device-onvif-camera.http:\/\/edgex-device-onvif-camera:59984/' ${compose}.yml
    fi

    # Add second modbus simulator
    sed -n "/^\ \ modbus-simulator:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/modbus-sim_1.yml
    sed -i 's/modbus-simulator/modbus-simulator_1/g' tmp/modbus-sim_1.yml
    sed -i "s/modbus-simulator_1${USE_ARM64}:latest/modbus-simulator${USE_ARM64}:latest/g" tmp/modbus-sim_1.yml
    sed -i 's/published: \"1502\"/published: "1512"/g' tmp/modbus-sim_1.yml
    sed -i "/services:/ r tmp/modbus-sim_1.yml" ${compose}.yml

    # URI for files
    if [ "${compose}" = "docker-compose" ]; then
      sed -n "/^\ \ device-onvif-camera:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/device-onvif-camera.yml
      if [ "${USE_SECURITY}" = '-' ]; then
        sed -n "/^\ \ core-metadata:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/core-metadata.yml
        sed -i "/\ \ \ \ environment:/a \ \ \ \ \ \ UOM_UOMFILE: ${HTTP_SERVER_DIR}/uom.yaml" tmp/core-metadata.yml
        sed -i "/\ \ \ \ environment:/a \ \ \ \ \ \ EDGEX_CONFIG_FILE: ${HTTP_SERVER_DIR}/config.yaml" tmp/device-onvif-camera.yml
        sed -i "/^\ \ core-metadata:/,/^  [a-z].*:$/{//!d}; /^\ \ core-metadata:/d" ${compose}.yml
        sed -i "/services:/ r tmp/core-metadata.yml" ${compose}.yml
      else
        sed -i "/\ \ \ \ environment:/a \ \ \ \ \ \ DEVICE_PROFILESDIR: .\/res" tmp/device-onvif-camera.yml
        sed -i "/\ \ \ \ environment:/a \ \ \ \ \ \ DEVICE_DEVICESDIR: .\/res" tmp/device-onvif-camera.yml
        sed -i "/\ \ \ \ environment:/a \ \ \ \ \ \ DEVICE_PROVISIONWATCHERSDIR: .\/res" tmp/device-onvif-camera.yml
      fi
      sed -i "/^\ \ device-onvif-camera:/,/^  [a-z].*:$/{//!d}; /^\ \ device-onvif-camera:/d" ${compose}.yml
      sed -i "/services:/ r tmp/device-onvif-camera.yml" ${compose}.yml
    fi

  elif [ "${TEST_STRATEGY}" = "functional-test" ]; then
    # Enable name field escape
      sed -n "/^\ \ core-common-config-bootstrapper:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/core-common-config-bootstrapper.yml
      sed -i '/\ \ \ \ environment:/a \ \ \ \ \ \ ALL_SERVICES_SERVICE_ENABLENAMEFIELDESCAPE: true' tmp/core-common-config-bootstrapper.yml
      sed -i "/^\ \ core-common-config-bootstrapper:/,/^  [a-z].*:$/{//!d}; /^\ \ core-common-config-bootstrapper:/d" ${compose}.yml
      sed -i "/services:/ r tmp/core-common-config-bootstrapper.yml" ${compose}.yml
  fi

  # Update services which use DOCKER_HOST_IP
  for service in support-notifications app-http-export; do
    sed -n "/^\ \ ${service}:/,/^  [a-z].*:$/p" ${compose}.yml | sed '$d' > tmp/${service}.yml
    sed -i 's/\EXPORT_HOST_PLACE_HOLDER/${DOCKER_HOST_IP}/g' tmp/${service}.yml
    sed -i '$a\ \ \ \ extra_hosts:' tmp/${service}.yml
    sed -i '$a\ \ \ \ -\ \"${DOCKER_HOST_IP}:host-gateway"' tmp/${service}.yml
    sed -i "/^\ \ ${service}:/,/^  [a-z].*:$/{//!d}; /^\ \ ${service}:/d" ${compose}.yml
    sed -i "/services:/ r tmp/${service}.yml" ${compose}.yml
  done

  sed -i '/PROFILE_VOLUME_PLACE_HOLDER: {}/d' ${compose}.yml

  # Update for backward competibility test
  if [ "${USE_SHA1}" = "jakarta" ]; then
    # Supported version:  Ireland, Jakarta, Kamakura
    sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/${EXTERNAL_BROKER_HOSTNAME}/g' ${compose}.yml
  else
    sed -i 's/\MQTT_BROKER_ADDRESS_PLACE_HOLDER/tcp:\/\/${EXTERNAL_BROKER_HOSTNAME}:1883/g' ${compose}.yml
  fi

  sed -i 's/\LOGLEVEL: INFO/LOGLEVEL: DEBUG/g' ${compose}.yml
  sed -i '/METRICSMECHANISM/d' ${compose}.yml  # remove METRICSMECHANISM env variable to allow change on Consul

  # Put HTTP Server On the top of compose file
  if [ "${TEST_STRATEGY}" = "integration-test" ] && [ "${compose}" = "docker-compose" ]; then
    sed -i "/services:/ r httpd/tools_yaml" ${compose}.yml

    # Download test data for URI for files
    sh get-uri-test-files.sh ${USE_SECURITY}
  fi
done
rm -rf tmp
