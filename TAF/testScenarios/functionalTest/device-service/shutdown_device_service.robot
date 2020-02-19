*** Settings ***
Documentation    Shutdown EdgeX
Library          TAF.utils.src.setup.setup_teardown
Library          TAF.utils.src.setup.edgex
Resource         TAF/testCaseModules/keywords/coreMetadataAPI.robot
Suite Setup      Setup Suite
Suite Teardown   Suite Teardown

*** Variables ***
${SUITE}              EdgeX shutdown
${WORK_DIR}           %{WORK_DIR}
${PROFILE}            %{PROFILE}
${LOG_FILE}           ${WORK_DIR}/TAF/testArtifacts/logs/edgex_shutdown.log

*** Keywords ***
# Setup called once before all test cases.
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Suite Setup

*** Test Cases ***
Shutdown Device Service
    Remove services  ${SERVICE_NAME}
    Delete device profile by name  Sample-Profile