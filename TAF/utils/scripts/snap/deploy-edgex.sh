#!/bin/bash

set -e

>&2 echo "INFO:snap-TAF: deploy-edgex: $*"
logger "INFO:snap-TAF: deploy-edgex: $*"

snap_install()
{
    local the_snap=$1
    local the_channel=$2
    local confinement=$3

    if [ "$the_snap" = "edgexfoundry" ] || [ "$the_snap" = "edgex-app-service-configurable" ]; then
        if [ -n "$confinement" ]; then
            snap install "$the_snap" --channel="$the_channel" "$confinement"
        else
            snap install "$the_snap" --channel="$the_channel"
        fi
    else
        if [ -n "$confinement" ]; then
            snap install "$the_snap" "$confinement"
        else
            snap install "$the_snap"
        fi
    fi
}

snap_remove_all()
{ 
    snap remove --purge edgex-device-modbus
    snap remove --purge edgex-app-service-configurable
    snap remove --purge edgexfoundry
}

snap_install_edgexfoundry()
{
    if [ ! -z $LOCAL_SNAP ]; then
        if [ -f "$LOCAL_SNAP" ]; then
            >&2 echo "INFO:snap: testing local snap: $LOCAL_SNAP"
            snap_install $LOCAL_SNAP "local" "--dangerous"
        else
            >&2 echo "ERROR:snap: local snap to test: \"$LOCAL_SNAP\" does not exist"
            exit 1
        fi
    else 
        >&2 echo "INFO:snap: testing 2.0/stable snap"
        snap_install edgexfoundry "2.0/stable"
    fi 

    snap start edgexfoundry.support-notifications
    snap start edgexfoundry.support-scheduler
    snap start edgexfoundry.sys-mgmt-agent

}

snap_install_asc() 
{
    local PROFILE=$1
     if [ ! -z $LOCAL_ASC_SNAP ]; then
        if [ -f "$LOCAL_ASC_SNAP" ]; then
            >&2 echo "INFO:snap: testing local ASC snap: $LOCAL_ASC_SNAP"
            snap_install $LOCAL_ASC_SNAP "local" "--dangerous"
        else
            >&2 echo "ERROR:snap: local snap to test: \"$LOCAL_ASC_SNAP\" does not exist"
            exit 1
        fi
    else 
        >&2 echo "INFO:snap: testing 2.0/stable snap"
        snap_install edgex-app-service-configurable "2.0/stable"
    fi 
 
   if [ ! -f "/var/snap/edgexfoundry/current/secrets/app-$PROFILE" ]; then
      >&2 echo "ERROR:snap: No Vault token for profile app-$PROFILE in edgexfoundry"  
    fi 
 
    snap connect edgexfoundry:edgex-secretstore-token edgex-app-service-configurable:edgex-secretstore-token

    if [ ! -f "/var/snap/edgex-app-service-configurable/current/app-$PROFILE" ]; then
      >&2 echo "ERROR:snap: No Vault token for profile app-$PROFILE in edgex-app-service-configurable"  
    fi 

    snap set edgex-app-service-configurable profile=$PROFILE
    snap start edgex-app-service-configurable
}

snap_install_devices()
{


    cp ${WORK_DIR}/TAF/config/device-virtual/sample_profile.yaml /var/snap/edgexfoundry/current/config/device-virtual/res/profiles

    snap install edgex-device-modbus --channel=2.0/stable
    cp ${WORK_DIR}/TAF/config/device-modbus/sample_profile.yaml /var/snap/edgex-device-modbus/current/config/device-modbus/res/profiles

    snap start edgexfoundry.device-virtual
    snap start edgex-device-modbus.device-modbus

}

snap_remove_all
snap_install_edgexfoundry
snap_install_asc functional-tests
snap_install_devices

sleep 5
