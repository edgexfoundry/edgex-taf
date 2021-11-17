#!/bin/sh
>&2 echo "INFO:snap-TAF: stop-services.sh"

for service in $@; do
    case $service in
      system)
        >&2 echo "INFO:snap-TAF: stop edgexfoundry.sys-mgmt-agent"
        sudo snap stop edgexfoundry.sys-mgmt-agent
        ;;
      notifications)
        >&2 echo "INFO:snap-TAF: stop edgexfoundry.support-notifications"
        sudo snap stop edgexfoundry.support-notifications
        ;;
     scheduler)
        >&2 echo "INFO:snap-TAF: stop edgexfoundry.support-scheduler"
        sudo snap stop edgexfoundry.support-scheduler
        ;;
      data)
        >&2 echo "INFO:snap-TAF: stop edgexfoundry.core-data"
        sudo snap stop edgexfoundry.core-data
        ;;
      metadata)
        >&2 echo "INFO:snap-TAF: stop edgexfoundry.core-metadata"
        sudo snap stop edgexfoundry.core-metadata
        ;;
      command)
        >&2 echo "INFO:snap-TAF: stop edgexfoundry.core-command"
        sudo snap stop edgexfoundry.core-command
        ;;
    *)    # unknown option
        >&2 echo "ERROR:snap-TAF: stop unknown service $service"
      ;;
    esac
  done     

sleep 10