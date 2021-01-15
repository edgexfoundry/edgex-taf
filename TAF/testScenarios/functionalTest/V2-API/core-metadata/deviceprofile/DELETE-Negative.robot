*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile DELETE Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-delete-negative.log
${api_version}    v2

*** Test Cases ***
ErrProfileDELETE001 - Delete device profile by non-existent name
    When Delete Device Profile By Name  Invalid_Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileDELETE002 - Delete device profile by name that used by device
    [Tags]  Skipped  # haven't implemented
    Given Create A Device Sample With Associated Test-Device-Service And Test-Profile-2
    When Delete Device Profile By Name  Test-Profile-2
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2
