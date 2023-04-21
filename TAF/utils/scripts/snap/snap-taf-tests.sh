#!/bin/bash -e

source "$SCRIPT_DIR/snap-utils.sh"

snap_taf_install_prerequisites()
{
  if [ ! -e "./edgex-taf-common" ]; then
        sudo apt-get install python-is-python3
        sudo apt-get install python3-pip
        git clone https://github.com/edgexfoundry/edgex-taf-common.git
        ## Install dependency lib
        pip3 install -r ./edgex-taf-common/requirements.txt
        ## Install edgex-taf-common as lib
        pip3 install ./edgex-taf-common
    else
        >&2 echo "INFO:snap: TAF prerequisites already installed"
    fi 


} 
 
snap_taf_patch_files()
{
    # TODO: Some of these changes should be submitted as Pull Requests to update the tests. 

    # 1: with snaps, everything is running on localhost. The Docker host names therefore need to be replaced
    sed -i -e 's@Host=edgex-support-scheduler@Host=localhost@' $WORK_DIR/TAF/testScenarios/functionalTest/API/support-scheduler/intervalaction/POST-Positive.robot
    sed -i -e 's@edgex-core-data@localhost@' $WORK_DIR/TAF/testScenarios/integrationTest/UC_data_clean_up/clean_up_events_and_readings.robot
    sed -i -e 's@edgex-core-command@localhost@' $WORK_DIR/TAF/testScenarios/integrationTest/UC_kuiper/export_by_kuiper_rules.robot

    # 2: Some of the integration tests don't specify which app-configurable profile is being used. They assume we are running with docker and 
    #    that all profiles are running. That can be fixed by changing the suite setup to include the profile name

     # For that to work we also need to modify APPServiceAPI.robot to set the app service port
    sed -i -e ':a;N;$!ba;s@:\n    Check@:\n    Set Environment Variable  SNAP_APP_SERVICE_PORT  ${port}[2]\n    Check@' $WORK_DIR/TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot

    sed -i -e ':a;N;$!ba;s@Setup Suite\n@Setup Suite for App Service  http://${BASE_URL}:${APP_EXTERNAL_MQTT_TRIGGER_PORT}\n@' $WORK_DIR/TAF/testScenarios/integrationTest/UC_app_service_configurable/external_mqtt_trigger.robot
    sed -i -e ':a;N;$!ba;s@Setup Suite\n@Setup Suite for App Service  http://${BASE_URL}:${APP_HTTP_EXPORT_PORT}\n@' $WORK_DIR/TAF/testScenarios/integrationTest/UC_end_to_end/export_data_to_backend.robot
    sed -i -e ':a;N;$!ba;s@Setup Suite\n@Setup Suite for App Service  http://${BASE_URL}:${APP_HTTP_EXPORT_PORT}\n@' $WORK_DIR/TAF/testScenarios/integrationTest/UC_end_to_end/export_store_forward.robot

    sed -i -e ':a;N;$!ba;s@Suite Setup  Run Keywords  Setup Suite\n@Resource         TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot\nSuite Setup  Run Keywords  Setup Suite for App Service  http://${BASE_URL}:${APP_MQTT_EXPORT_PORT}\n@' $WORK_DIR/TAF/testScenarios/integrationTest/UC_mqtt_message_bus/device_virtual_config.robot
    sed -i -e ':a;N;$!ba;s@Suite Setup  Run Keywords  Setup Suite\n@Resource         TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot\nSuite Setup  Run Keywords  Setup Suite for App Service  http://${BASE_URL}:${APP_MQTT_EXPORT_PORT}\n@' $WORK_DIR/TAF/testScenarios/integrationTest/UC_mqtt_message_bus/core_data_config.robot
      
    # 3: Change the config from "docker" to "snap"
    sed -i -e 's@"docker"@"snap"@' $WORK_DIR/TAF/config/global_variables.py

    # 4: for the tokens - change docker-specific commands and path names to snap-specific ones
    sed -i -e 's@docker exec edgex-core-consul cat /tmp/edgex/secrets/@cat /var/snap/edgexfoundry/current/secrets/@' $WORK_DIR/TAF/testCaseModules/keywords/common/commonKeywords.robot
    sed -i -e 's@docker exec edgex-${app_service_name} cat /tmp/edgex/secrets@cat /var/snap/edgex-app-service-configurable/current@' $WORK_DIR/TAF/testScenarios/functionalTest/API/app-service/secrets/POST.robot

    sed -i -e 's@/tmp/edgex/secrets@/var/snap/edgexfoundry/current/secrets@' $WORK_DIR/TAF/utils/src/setup/redis-subscriber.py

    # 5: logging is done using journalctl
    sed -i -e "s!\"docker logs edgex-{} --since {}\"!\"journalctl -q -g {} -S @{} || true\"!" $WORK_DIR/TAF/testCaseModules/keywords/setup/edgex.py 
    sed -i -e 's!"docker logs {}"!"journalctl -g {}"!' $WORK_DIR/TAF/testCaseModules/keywords/setup/startup_checker.py

    # 6. Other issues:
    # in case python2 is the default, replace it with python3 (can also be done by apt-get install python3-is-python)
    sed -s -i -e 's@Start process  python @Start process  python3 @' $WORK_DIR/TAF/testScenarios/functionalTest/API/support-notifications/transmission/*.robot

    #  remove system-agent tests - we don't run them because the system agent service has been deprecated since the Ireland release (2.0)
    rm -rf $WORK_DIR/TAF/testScenarios/functionalTest/API/system-agent/info
    rm -rf $WORK_DIR/TAF/testScenarios/functionalTest/API/system-agent/services

    #  The notification sender is "core-metadata", not "edgex-core-metadata"
    sed -i -e 's@edgex-core-metadata@core-metadata@' $WORK_DIR/TAF/testScenarios/integrationTest/UC_metadata_notifications/metadata_notifications.robot

    # this test assumes we are running on two different IP addresses. Set DOCKER_IP to an invalid IP in this case as otherwise we get duplicate transmissions
    sed -i -e 's@${DOCKER_HOST_IP}@"invalid-ip"@' $WORK_DIR/TAF/testScenarios/functionalTest/API/support-notifications/transmission/GET-Positive.robot


    # 7. changes having to do with mosquitto
    
    # edgex-mqtt-broker is mosquitto, as per https://github.com/edgexfoundry/developer-scripts/blob/5af601bb1938c1ad76d6b3e7e113bdfc088f9f48/compose-builder/add-mqtt-broker.yml
    sed -i -e 's@edgex-mqtt-broker@localhost@' $WORK_DIR/TAF/testData/kuiper/action.json

    sed -i -e "s!docker logs edgex-mqtt-broker --since ${log_timestamp}!journalctl -q -u snap.mosquitto.mosquitto.service -S \@${log_timestamp}!" $WORK_DIR/TAF/testScenarios/integrationTest/UC_mqtt_message_bus/core_data_config.robot
    sed -i -e "s!docker logs edgex-mqtt-broker --since ${timestamp}!journalctl -q -u snap.mosquitto.mosquitto.service -S \@${timestamp}!" $WORK_DIR/TAF/testScenarios/integrationTest/UC_mqtt_message_bus/device_virtual_config.robot
 
}




snap_taf_enable_snap_testing()
{
   snap_taf_patch_files
     
   # set this for the tests that need it
   export DOCKER_HOST_IP="localhost"

}

snap_taf_deploy_edgex()
{
   cd ${WORK_DIR}
    # 1. Deploy EdgeX
    python3 -m TUC --exclude Skipped --include deploy-base-service -u deploy.robot -p default
 
    mkdir -p "$WORK_DIR/TAF/testArtifacts/reports/cp-edgex/"
}

snap_taf_run_functional_tests() # arg:  tests to run
{
    # required by the functional tests, but not by integration tests
    snap_install_device_camera
   
    cd ${WORK_DIR}

    # 2. Run API Functional testing (using directories in TAF/testScenarios/functionalTest/API )
    # 
    rm -f $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/api-test.html
    
    if [ "$1" = "all" ]; then  
        python3 -m TUC --exclude Skipped -u functionalTest/API/ -p default
        cp $WORK_DIR/TAF/testArtifacts/reports/edgex/log.html $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/api-test.html
        >&2 echo "INFO:snap: Test report copied to $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/api-test.html"
    elif [ ! -z "$1" ]; then
        python3 -m TUC --exclude Skipped -u functionalTest/API/${1} -p default
        cp $WORK_DIR/TAF/testArtifacts/reports/edgex/log.html $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/api-test.html
        >&2 echo "INFO:snap: API Test report copied to $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/api-test.html"
    fi
  
}

snap_taf_run_functional_device_tests()
{
    export EDGEX_SECURITY_SECRET_STORE=false
    export SECURITY_SERVICE_NEEDED=false  
    
  
    # 3. Run device functional tests
    for profile in $@; do
        >&2 echo "INFO:snap: testing $profile"
        python3 -m TUC --exclude Skipped -u functionalTest/device-service -p ${profile}
        rm -f $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/${profile}-test.html
        cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/${profile}-test.html
        >&2 echo "INFO:snap: API Device Test report copied to ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/${profile}-test.html "
    done    
}

snap_taf_run_integration_tests()
{
    local INCLUDE_TESTS=$1
    local LOG_TARGET=$2
    rm -f $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/$LOG_TARGET 

   
    cd ${WORK_DIR}
    python3 -m TUC --exclude Skipped --include $INCLUDE_TESTS -u integrationTest -p device-virtual
    cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/$LOG_TARGET

    >&2 echo "INFO:snap: API Device Test report copied to ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/"

  
 }

snap_taf_shutdown()
{
    cd ${WORK_DIR}
    python3 -m TUC --exclude Skipped --include shutdown-edgex -u shutdown.robot -p default
    >&2 echo "INFO:snap: Reports are in ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex"

}