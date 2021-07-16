#!/bin/bash

# Arguments 
INSTALL_PREREQUISITES=false
INSTALL_EDGEX=true
CLEANUP_EDGEX=true

# open the html reports in a browser when done
OPEN_REPORTS=true

# leave empty to skip tests
# set to "all" to run all tests
# or set to one of app-service core-command core-data core-metadata support-notifications support-scheduler system-agent
V2_API_FUNCTIONAL_TESTS=all


# leave empty to skip tests
V2_API_FUNCTIONAL_DEVICE_TESTS=("device-virtual")
# "device-virtual" "device-modbus"
#RUN_INTEGRATION_TESTS=true




export ARCH=x86_64
export SECURITY_SERVICE_NEEDED=true 



# constants
BASEDIR=$(pwd)
export WORK_DIR=${BASEDIR}/../../../..

# Install prerequisites
if [ "$INSTALL_PREREQUISITES" = true ]; then
    sudo apt-get install python3-pip
    cd ${HOME}/edgex-taf
    git clone https://github.com/edgexfoundry/edgex-taf-common.git
    ## Install dependency lib
    pip3 install -r ./edgex-taf-common/requirements.txt
    ## Install edgex-taf-common as lib
    pip3 install ./edgex-taf-common
fi

# modify `TAF/config/global_variables.py`
sed -i -e 's@"docker"@"snap"@' $WORK_DIR/TAF/config/global_variables.py

cd ${WORK_DIR}

# 1. Deploy EdgeX
if [ "$INSTALL_EDGEX" = true ]; then  
    python3 -m TUC --exclude Skipped --include deploy-base-service -u deploy.robot -p default
fi


# 2. Run V2 API Functional testing (using directories in TAF/testScenarios/functionalTest/V2-API )
# 
if [ -e "${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html" ]; then
    rm ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html
fi

if [ "$V2_API_FUNCTIONAL_TESTS" = "all" ]; then  
   python3 -m TUC --exclude Skipped --include v2-api -u functionalTest/V2-API/ -p default    
   cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html
elif [ ! -z "$V2_API_FUNCTIONAL_TESTS" ]; then
   python3 -m TUC --exclude Skipped --include v2-api -u functionalTest/V2-API/${V2_API_FUNCTIONAL_TESTS} -p default    
   cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html
fi

if ["$OPEN_REPORTS" = true ]; then
    if [ -e "${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html" ]; then
        open ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-api-test.html
    fi
fi


# 3. Run device functional tests
for profile in ${V2_API_FUNCTIONAL_DEVICE_TESTS[@]}; do
    echo "[snap] testing $profile"
    python3 -m TUC --exclude Skipped -u functionalTest/device-service -p ${profile}
    cp ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-${profile}-test.html
    if ["$OPEN_REPORTS" = true ]; then
        open ${WORK_DIR}/TAF/testArtifacts/reports/cp-edgex/v2-${profile}-test.html
    fi
done    


# 4. Run Integration testing

#if [ "$RUN_INTEGRATION_TESTS" = true ]; then  
#    python3 -m TUC --exclude Skipped -u integrationTest -p device-virtual
#fi


#5. Shutdown
if [ "$CLEANUP_EDGEX" = true ]; then  
    python3 -m TUC --exclude Skipped --include shutdown-edgex -u shutdown.robot -p default
fi

