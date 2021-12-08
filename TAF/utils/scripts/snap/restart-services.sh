#!/bin/sh
>&2 echo "INFO:snap-TAF: restart-services.sh"


for service in $@; do
    case $service in
     device-rest)
        >&2 echo "INFO:snap-TAF: restart edgex-device-rest.device-rest"
        sudo snap restart edgex-device-rest.device-rest
        ;;
      device-virtual)
        >&2 echo "INFO:snap-TAF: restart edgexfoundry.device-virtual"
        sudo snap restart edgexfoundry.device-virtual
        ;;
      mqtt-broker)
        >&2 echo "INFO:snap-TAF: restart mosquitto"
        sudo snap restart mosquitto
        ;;
      app-*)
        >&2 echo "INFO:snap-TAF: restart edgex-app-service-configurable.app-service-configurable"
        sudo snap restart edgex-app-service-configurable.app-service-configurable 
        ;; 
      system)
        >&2 echo "INFO:snap-TAF: restart edgexfoundry.sys-mgmt-agent"
        sudo snap restart edgexfoundry.sys-mgmt-agent
        ;;
      notifications)
        >&2 echo "INFO:snap-TAF: restart edgexfoundry.support-notifications"
        sudo snap restart edgexfoundry.support-notifications
        ;;
     scheduler)
        >&2 echo "INFO:snap-TAF: restart edgexfoundry.support-scheduler"
        sudo snap restart edgexfoundry.support-scheduler
        ;;
      data)
        >&2 echo "INFO:snap-TAF: restart edgexfoundry.core-data"
        sudo snap restart edgexfoundry.core-data
        ;;
      metadata)
        >&2 echo "INFO:snap-TAF: restart edgexfoundry.core-metadata"
        sudo snap restart edgexfoundry.core-metadata
        ;;
      command)
        >&2 echo "INFO:snap-TAF: restart edgexfoundry.core-command"
        sudo snap restart edgexfoundry.core-command
        ;;
      *)    # unknown option
        >&2 echo "ERROR:snap-TAF: restart unknown service $service"
        logger "ERROR:snap-TAF: restart unknown service $service"
      ;;
    esac
    sleep 1
  done     
  sleep 1