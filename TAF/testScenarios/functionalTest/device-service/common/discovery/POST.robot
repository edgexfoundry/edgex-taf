*** Settings ***
Library      TAF/testCaseModules/keywords/setup/edgex.py
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Device SDK Discovery POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/device-sdk-discovery.log
${url}            ${deviceServiceUrl}

*** Test Cases ***
ErrDiscoveryPOST001 - Service's adminState is locked
    Given Update Device Service adminState to LOCKED
    When Run Discovery Request For Device Service
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Update Device Service adminState to UNLOCKED

ErrDiscoveryPOST002 - Discovery is disabled by configuration
    When Run Discovery Request For Device Service
    Then Should Return Status Code "503"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms


*** Keywords ***
Update Device Service adminState to ${value}
    ${service_list}=  Create List
    ${json}  Create Dictionary  name=${SERVICE_NAME}  adminState=${value}
    ${deviceService}  Create Dictionary  service=${json}  apiVersion=${API_VERSION}
    Append To List  ${service_list}  ${deviceService}
    Update Device Service ${service_list}

