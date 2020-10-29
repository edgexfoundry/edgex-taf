*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-delete.log
${api_version}    v2

*** Test Cases ***
DeviceDELETE001 - Delete device by ID
    Given Create A Device Sample With Associated Test-Device-Service And Test-Profile-1
    And Get "id" From Multi-status Item 0
    When Delete Device By ID  ${item_value}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Should Be Deleted
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

DeviceDELETE002 - Delete device by name
    [Tags]  SmokeTest
    Given Create A Device Sample With Associated Test-Device-Service And Test-Profile-2
    When Delete Device By Name Test-Device
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Should Be Deleted
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

ErrDeviceDELETE001 - Delete device by ID with invalid id format
    # use non uuid format, like d138fccc-f39a4fd0-bd32
    When Delete Device Service By ID  d138fccc-f39a4fd0-bd32
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrDeviceDELETE002 - Delete device by ID with non-existent ID
    ${random_uuid}=  Evaluate  str(uuid.uuid4())
    When Delete Device Service By ID  ${random_uuid}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrDeviceDELETE003 - Delete device by name with non-existent name
    When Delete Device By Name Non-Existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Device Should Be Deleted
    Check existence of device by name   Test-Device
    Should Return Status Code "404"
