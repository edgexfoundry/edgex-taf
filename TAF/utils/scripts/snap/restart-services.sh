#!/bin/sh
CONF_DIR=/custom-config

for service in $@; do
    case $service in
      device-virtual)
        logger "INFO:snap-TAF: restart edgexfoundry.device-virtual"
        sudo snap restart edgexfoundry.device-virtual
        ;;
      app-service-http-export)
        logger "INFO:snap-TAF: restart edgex-app-service-configurable.app-service-configurable"
        sudo snap restart edgex-app-service-configurable.app-service-configurable 
        ;;
      *)    # unknown option
        logger "ERROR:snap-TAF: restart unknown service $service"
      ;;
    esac
  done     