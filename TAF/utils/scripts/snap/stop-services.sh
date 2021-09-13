#!/bin/sh
logger "INFO:snap-TAF: stop-services.sh"

for service in $@; do
    case $service in
      system)
        logger "INFO:snap-TAF: stop edgexfoundry.sys-mgmt-agent"
        sudo snap stop edgexfoundry.sys-mgmt-agent
        ;;
      notifications)
        logger "INFO:snap-TAF: stop edgexfoundry.support-notifications"
        sudo snap stop edgexfoundry.support-notifications
        ;;
     scheduler)
        logger "INFO:snap-TAF: stop edgexfoundry.support-scheduler"
        sudo snap stop edgexfoundry.support-scheduler
        ;;
      data)
        logger "INFO:snap-TAF: stop edgexfoundry.core-data"
        sudo snap stop edgexfoundry.core-data
        ;;
      metadata)
        logger "INFO:snap-TAF: stop edgexfoundry.core-metadata"
        sudo snap stop edgexfoundry.core-metadata
        ;;
      command)
        logger "INFO:snap-TAF: stop edgexfoundry.core-command"
        sudo snap stop edgexfoundry.core-command
        ;;
    *)    # unknown option
        logger "ERROR:snap-TAF: stop unknown service $service" 
      ;;
    esac
  done     

sleep 10