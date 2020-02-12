*** Settings ***
Documentation    Deploy EdgeX
Library          TAF.utils.src.setup.setup_teardown
Library          TAF.utils.src.setup.edgex
Library          TAF.utils.src.setup.consul
Suite Setup      Setup Suite
Suite Teardown   Suite Teardown

*** Variables ***
${SUITE}         EdgeX deployment
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/edgex_deployment.log

*** Keywords ***
# Setup called once before all test cases.
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Suite Setup

*** Test Cases ***
Deploy EdgeX
    Deploy edgex
