#!/bin/bash -e

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
    snap remove --purge edgex-app-service-configurable
    snap remove --purge edgex-device-mqtt
    snap remove --purge edgex-device-modbus
    snap remove --purge edgex-device-camera
    snap remove --purge edgex-device-rest
    snap remove --purge edgexfoundry
    snap remove --purge mosquitto
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
        >&2 echo "INFO:snap: testing latest/edge snap"
        snap_install edgexfoundry "latest/edge"
    fi 


}

snap_start_asc()
{
    >&2 snap start edgex-app-service-configurable
}

snap_stop_asc()
{
    >&2 echo "INFO:snap-TAF: stopping app-service-configurable"
    >&2 snap stop edgex-app-service-configurable
}

snap_set_asc_profile()
{
    local PROFILE=$1
    >&2 echo "INFO:snap-TAF: snap_set_asc_profile: switching to $PROFILE profile"
    >&2 snap set edgex-app-service-configurable profile=$PROFILE
    >&2 snap restart edgex-app-service-configurable
}

snap_taf_update_consul()
{
    # Update Consul to prevent "Your IP is issuing too many concurrent connections, please rate limit your calls"
    sed -i -e 's@"disable@"limits": { "http_max_conns_per_client": 65536}, "disable@' /var/snap/edgexfoundry/current/consul/config/consul_default.json 
    snap restart edgexfoundry.security-proxy-setup
}

snap_set_messagebus_to_mqtt()
{
    # note that the integration tests use mqtt as the bus https://github.com/edgexfoundry/edgex-compose/blob/main/taf/docker-compose-taf-mqtt-bus.yml
    #      
    # rules-engine
 #   snap set edgexfoundry env.app-service-configurable.edgex-message-bus.port="1883"
 #   snap set edgexfoundry env.app-service-configurable.edgex-message-bus.protocol="tcp"
  #snap set edgexfoundry env.app-service-configurable.edgex-message-bus.type="mqtt"

    # rule engine
    ASC_FILE=/var/snap/edgexfoundry/current/config/app-service-configurable/res/app-service-configurable.env
    echo "export MESSAGEBUS_PORT=1883"  |  tee -a $ASC_FILE > /dev/null
    echo "export MESSAGEBUS_PROTOCOL=tcp"  |  tee -a $ASC_FILE > /dev/null
    echo "export MESSAGEBUS_TYPE=mqtt"  | tee -a $ASC_FILE > /dev/null
    >&2 snap restart edgexfoundry.app-service-configurable

    #core-data
#    snap set edgexfoundry env.core-data.messagebus.optional.clientid="core-data"
    >&2 snap set edgexfoundry env.core-data.messagebus.host="localhost" # edgex-mqtt-broker
    >&2 snap set edgexfoundry env.core-data.messagebus.port="1883"
    >&2 snap set edgexfoundry env.core-data.messagebus.protocol="tcp"
    >&2 snap set edgexfoundry env.core-data.messagebus.type="mqtt"
    >&2 snap restart edgexfoundry.core-data 

   #device-virtual
    >&2 snap set edgexfoundry env.device-virtual.messagebus.host="localhost" # edgex-mqtt-broker
    >&2 snap set edgexfoundry env.device-virtual.messagebus.port="1883"
    >&2 snap set edgexfoundry env.device-virtual.messagebus.protocol="tcp"
    >&2 snap set edgexfoundry env.device-virtual.messagebus.type="mqtt"
    >&2 snap restart edgexfoundry.device-virtual 

 
    # asc (mqtt export/http export/external-mqtt-trigger)
    ASC_FILE=/var/snap/edgex-app-service-configurable/current/config/res/app-service-configurable.env
    echo "export MESSAGEBUS_PORT=1883"  |  tee -a $ASC_FILE > /dev/null
    echo "export MESSAGEBUS_PROTOCOL=tcp"  |  tee -a $ASC_FILE > /dev/null
    echo "export MESSAGEBUS_TYPE=mqtt"  | tee -a $ASC_FILE > /dev/null
    >&2 snap restart edgex-app-service-configurable

    >&2 sudo snap restart mosquitto
  

    
     >&2 echo "INFO:snap-TAF: Switched to using MQTT Message Bus"
     
}


snap_update_profiles()
{
    # The docker compose scripts in https://github.com/edgexfoundry/edgex-compose/blob/2a75ddbc5474e079106d3bac7fcb726271b75f59/taf/docker-compose-taf.yml
    # set up the app service configurable services, including http_export exporting to port 7770
 # besides using the compose files, see also the get-compose-file.sh script in TAF

    sed -i -e 's@https://f095cfcd-a3f6-4885-85ea-7157c6afd17e.mock.pstmn.io@http://localhost:7770@' /var/snap/edgex-app-service-configurable/current/config/res/http-export/configuration.toml 
    sed -i -e 's@Topic = \"edgex-export\"@Topic = \"edgex-events\"@' /var/snap/edgex-app-service-configurable/current/config/res/mqtt-export/configuration.toml 
    
    sed -i -e 's@LogLevel = \"INFO\"@LogLevel = \"DEBUG\"@' /var/snap/edgex-app-service-configurable/current/config/res/http-export/configuration.toml 
    sed -i -e 's@LogLevel = \"INFO\"@LogLevel = \"DEBUG\"@' /var/snap/edgex-app-service-configurable/current/config/res/mqtt-export/configuration.toml 
   sed -i -e 's@LogLevel = \"INFO\"@LogLevel = \"DEBUG\"@' /var/snap/edgex-app-service-configurable/current/config/res/external-mqtt-trigger/configuration.toml 


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
        >&2 echo "INFO:snap: testing latest/edge snap"
        snap_install edgex-app-service-configurable "latest/edge"
    fi 
 
   if [ ! -d "/var/snap/edgexfoundry/current/secrets/app-$PROFILE" ]; then
      >&2 echo "ERROR:snap: No Vault token for profile app-$PROFILE in edgexfoundry"  
       exit 1
    fi 
 
    snap connect edgexfoundry:edgex-secretstore-token edgex-app-service-configurable:edgex-secretstore-token

    if [ ! -d "/var/snap/edgex-app-service-configurable/current/app-$PROFILE" ]; then
      >&2 echo "ERROR:snap: No Vault token for profile app-$PROFILE in edgex-app-service-configurable."
       exit 1
    fi 

    # replicate the work done in Docker compose files, modifying the profiles
    snap_update_profiles

    snap set edgex-app-service-configurable profile=$PROFILE
    snap start edgex-app-service-configurable
}


snap_start_device_rest()
{
    snap install edgex-device-rest --channel=latest/edge
    # this is required if we are not using a edgexfoundry snap from the snap store
    snap connect edgexfoundry:edgex-secretstore-token edgex-device-rest:edgex-secretstore-token
    snap start edgex-device-rest.device-rest
}

snap_install_device_camera()
{
    snap install edgex-device-camera --channel=latest/edge
    # this is required if we are not using a edgexfoundry snap from the snap store
    snap connect edgexfoundry:edgex-secretstore-token edgex-device-camera:edgex-secretstore-token
    snap start edgex-device-camera.device-camera
    
}


snap_start_device_virtual()
{
    rm -f /var/snap/edgexfoundry/current/config/device-virtual/res/devices/*
    rm -f  /var/snap/edgexfoundry/current/config/device-virtual/res/profiles/*
    cp ${WORK_DIR}/TAF/config/device-virtual/sample_profile.yaml /var/snap/edgexfoundry/current/config/device-virtual/res/profiles/
    snap start edgexfoundry.device-virtual
    
}
snap_start_support_services()
{
    snap start edgexfoundry.support-notifications
    snap start edgexfoundry.support-scheduler
    snap start edgexfoundry.sys-mgmt-agent
}

snap_start_kuiper()
{
    snap start edgexfoundry.kuiper
}

snap_start_edgexfoundry_rules_engine()
{
    snap start edgexfoundry.app-service-configurable
}

snap_install_device_modbus()
{
    snap install edgex-device-modbus --channel=latest/edge
    rm -f /var/snap/edgex-device-modbus/current/config/device-modbus/res/devices/*
    rm -f /var/snap/edgex-device-modbus/current/config/device-modbus/res/profiles/*
    snap connect edgexfoundry:edgex-secretstore-token edgex-device-modbus:edgex-secretstore-token
    cp ${WORK_DIR}/TAF/config/device-modbus/sample_profile.yaml /var/snap/edgex-device-modbus/current/config/device-modbus/res/profiles/
    snap start edgex-device-modbus.device-modbus
}
 
snap_taf_patch_mosquitto()
{
    # the qOS tests require verbose mosquitto output
    echo "log_type all" | sudo tee -a /var/snap/mosquitto/common/mosquitto.conf > /dev/null
    snap restart mosquitto
}



snap_install_all()
{
    kill_python_processes
    snap install mosquitto
    snap_taf_patch_mosquitto
    snap_install_edgexfoundry
    snap_start_support_services
    snap_start_device_virtual
    snap_start_edgexfoundry_rules_engine
    snap_start_device_rest
    snap_start_kuiper
    snap_install_device_modbus

    snap_install_asc functional-tests
}

kill_python_process()
{
    local the_process=$1

    if pgrep -f $the_process > /dev/null
    then
        >&2 echo "INFO:snap-TAF: killing python $the_process process"
        >&2 kill $(pgrep -f $the_process)
    fi
}

# the python httpd_server.py process is sometimes left hanging which causes the next run to fail
kill_python_processes()
{
    kill_python_process "httpd_server.py"
    kill_python_process "mqtt-publisher.py"
    kill_python_process "mqtt-subscriber.py"
    kill_python_process "redis-subscriber.py"
}

snap_get_asc_profile_from_port()
{
    case ${SNAP_APP_SERVICE_PORT} in
        59703)
        SNAP_APP_SERVICE_PROFILE="mqtt-export"
        ;;
        59704)
        SNAP_APP_SERVICE_PROFILE="http-export"
        ;;
        59705)
        SNAP_APP_SERVICE_PROFILE="functional-tests"
        ;;
        59706)
        SNAP_APP_SERVICE_PROFILE="external-mqtt-trigger"
        ;;
        *)
        >&2 echo "ERROR:snap-TAF: api-gateway-token: unsupported service on port  ${SNAP_APP_SERVICE_PORT}"
        SNAP_APP_SERVICE_PROFILE=""
        ;;
    esac 
}


snap_maybe_switch_asc_profile()
{
  
  
    # This script gets called at the beginning of each test suite. It's therefore the
    # best location to check if we should use a different app-service-configurable profile
    # note that this depends on a change to AppServiceAPI.robot:
    #   Check app-service is available
    #    ${port}=  Split String  ${url}  :
    #    Set Environment Variable  SNAP_APP_SERVICE_PORT  ${port}[2]
    #    Check service is available  ${port}[2]   /api/v3/ping

    # also - this script should not write anything but the token to stdout
    if [ ! -z "$SNAP_APP_SERVICE_PORT" ]; then
 
        snap_get_asc_profile_from_port

        CURRENTPROFILE=`snap get edgex-app-service-configurable profile`
        if [ "$CURRENTPROFILE" != "$SNAP_APP_SERVICE_PROFILE" ]; then
             >&2 echo "INFO:snap-TAF: switching to ASC profile $SNAP_APP_SERVICE_PROFILE ($SNAP_APP_SERVICE_PORT)"
              snap_set_asc_profile $SNAP_APP_SERVICE_PROFILE
            sleep 5
        else
            >&2 echo "INFO:snap-TAF: ASC profile unchanged  $SNAP_APP_SERVICE_PROFILE ($SNAP_APP_SERVICE_PORT)"
        fi
        SNAP_APP_SERVICE_PORT=""

        # in case it was stopped
        snap_start_asc
    else
        >&2 echo "INFO:snap-TAF: api-snap_maybe_switch_asc_profile-token: no ASC profile has been specified. Stopping App-service-configurable"
        snap_stop_asc
    fi

}