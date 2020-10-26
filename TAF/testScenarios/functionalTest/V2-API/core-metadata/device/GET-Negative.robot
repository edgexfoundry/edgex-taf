*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-get-negative.log
${api_version}    v2

*** Test Cases ***
ErrDeviceGET001 - Query device by non-existent device name
    When Run Keyword And Expect Error  *  Query Device By Name  Non-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrDeviceGET002 - Check device exists by non-existent device name
    When Check Existence Of Device By Name  Non-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrDeviceGET003 - Query devices with empty device profile name
    [Tags]  Skipped
    Given Create Device Profile
    When Query All Devices With Specified Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile

ErrDeviceGET004 - Query all devices with empty device service name
    [Tags]  Skipped
    Given Create Device Service
    When Query All Devices With Specified Device Service
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Services

ErrDeviceGET005 - Query all devices with non-int value on offset/limit
    When Run Keyword And Expect Error  *  Query All Devices With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrDeviceGET006 - Query all devices with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Devices With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

