*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-delete.log
${api_version}    v2

*** Test Cases ***
DeviceDELETE001 - Delete device by name
    Given Create A Device Sample With Associated Test-Device-Service And Test-Profile-2
    When Delete Device By Name Test-Device
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Should Be Deleted
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

ErrDeviceDELETE001 - Delete device by name with non-existent name
    When Delete Device By Name Non-Existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Device Should Be Deleted
    Check existence of device by name   Test-Device
    Should Return Status Code "404"
