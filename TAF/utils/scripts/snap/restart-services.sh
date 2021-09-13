#!/bin/sh
logger "INFO:snap-TAF: restart-services.sh"

 

for service in $@; do
    case $service in
     device-rest)
        logger "INFO:snap-TAF: restart edgex-device-rest.device-rest"
        sudo snap restart edgex-device-rest.device-rest
        ;;
      device-virtual)
        logger "INFO:snap-TAF: restart edgexfoundry.device-virtual"
        sudo snap restart edgexfoundry.device-virtual
        ;;
      app-service-*)
        logger "INFO:snap-TAF: restart edgex-app-service-configurable.app-service-configurable"
        sudo snap restart edgex-app-service-configurable.app-service-configurable 
        ;; 
      system)
        logger "INFO:snap-TAF: restart edgexfoundry.sys-mgmt-agent"
        sudo snap restart edgexfoundry.sys-mgmt-agent
        ;;
      notifications)
        logger "INFO:snap-TAF: restart edgexfoundry.support-notifications"
        sudo snap restart edgexfoundry.support-notifications
        ;;
     scheduler)
        logger "INFO:snap-TAF: restart edgexfoundry.support-scheduler"
        sudo snap restart edgexfoundry.support-scheduler
        ;;
      data)
        logger "INFO:snap-TAF: restart edgexfoundry.core-data"
        sudo snap restart edgexfoundry.core-data
        ;;
      metadata)
        logger "INFO:snap-TAF: restart edgexfoundry.core-metadata"
        sudo snap restart edgexfoundry.core-metadata
        ;;
      command)
        logger "INFO:snap-TAF: restart edgexfoundry.core-command"
        sudo snap restart edgexfoundry.core-command
        ;;
      *)    # unknown option
        logger "ERROR:snap-TAF: restart unknown service $service"
      ;;
    esac
  done     

sleep 5