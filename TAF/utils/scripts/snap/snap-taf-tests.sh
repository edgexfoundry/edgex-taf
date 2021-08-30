#!/bin/bash -e


snap_taf_install_prerequisites()
{
  if [ ! -e "./edgex-taf-common" ]; then
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
 
snap_taf_enable_snap_testing() 
{

    # modify `TAF/config/global_variables.py`
    sed -i -e 's@"docker"@"snap"@' $WORK_DIR/TAF/config/global_variables.py

    # modify commonKeywords.robot
    sed -i -e 's@docker exec edgex-core-consul cat /tmp/edgex/secrets/@cat /var/snap/edgexfoundry/current/secrets/@' $WORK_DIR/TAF/testCaseModules/keywords/common/commonKeywords.robot

    # modify POST.robot
    sed -i -e 's@docker exec edgex-${app_service_name} cat /tmp/edgex/secrets@cat /var/snap/edgex-app-service-configurable/current@' $WORK_DIR/TAF/testScenarios/functionalTest/V2-API/app-service/secrets/POST.robot

    # modify APPServiceAPI.robot
    sed -i -e ':a;N;$!ba;s@:\n    Check@:\n    Set Environment Variable  SNAP_APP_SERVICE_PORT  ${port}[2]\n    Check@' $WORK_DIR/TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
   



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
   cd ${WORK_DIR}

    # 2. Run V2 API Functional testing (using directories in TAF/testScenarios/functionalTest/V2-API )
    # 
    rm -f $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html
    
    if [ "$1" = "all" ]; then  
        python3 -m TUC --exclude Skipped --include v2-api -u functionalTest/V2-API/ -p default    
        cp $WORK_DIR/TAF/testArtifacts/reports/edgex/log.html $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html
        >&2 echo "INFO:snap: Test report copied to $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html"
    elif [ ! -z "$1" ]; then
        python3 -m TUC --exclude Skipped --include v2-api -u functionalTest/V2-API/${1} -p default    
        cp $WORK_DIR/TAF/testArtifacts/reports/edgex/log.html $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html
        >&2 echo "INFO:snap: V2 API Test report copied to $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html"
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
        rm -f $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/v2-${profile}-test.html 
        cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-${profile}-test.html 
        >&2 echo "INFO:snap: V2 API Device Test report copied to ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-${profile}-test.html "
    done    
}

snap_taf_run_integration_tests()
{
    rm -f $WORK_DIR/TAF/testArtifacts/reports/cp-edgex/integration-test.html 
 
    cd ${WORK_DIR}
    python3 -m TUC --exclude Skipped -u integrationTest -p device-virtual
    cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/integration-test.html 
    >&2 echo "INFO:snap: V2 API Device Test report copied to ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/integration-test.html"
 }

snap_taf_shutdown()
{
    cd ${WORK_DIR}
    python3 -m TUC --exclude Skipped --include shutdown-edgex -u shutdown.robot -p default
    >&2 echo "INFO:snap: Reports are in ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex"

}