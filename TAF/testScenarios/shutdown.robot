*** Settings ***
Documentation    Shutdown EdgeX
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Library          TAF/testCaseModules/keywords/setup/edgex.py
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup      Setup Suite
Suite Teardown   Suite Teardown

*** Variables ***
${SUITE}              EdgeX shutdown
${WORK_DIR}           %{WORK_DIR}
${LOG_FILE}           ${WORK_DIR}/TAF/testArtifacts/logs/edgex_shutdown.log

*** Keywords ***
# Setup called once before all test cases.
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Suite Setup

*** Test Cases ***
Shutdown EdgeX
    [Tags]  shutdown-edgex
    Shutdown services

Shutdown Device Service
    [Tags]  shutdown-device-service
    Remove services  ${SERVICE_NAME}
    Delete device profile by name  ${PREFIX}-Sample-Profile
