*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-get-negative.log

*** Test Cases ***
ErrProfileGET001 - Query device profile by non-existent name
    When Run Keyword And Expect Error  *  Query Device Profile By Name  Non-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET002 - Query device profiles by manufacturer with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Device Profiles By Manufacturer Honeywell With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET003 - Query device profiles by manufacturer and model with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Device Profiles Having Manufacturer Honeywell And Model ABC123
    ...                                   With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET004 - Query device profiles by model with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Device Profiles By Model ABC123 With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET005 - Query all device profile with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Device Profiles With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET006 - Query all device profile with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Device Profiles By Manufacturer Honeywell With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET007 - Query all device profile by manufacturer with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Device Profiles With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET008 - Query all device profile by model with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Device Profiles By Model ABC123 With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET009 - Query all device profile by manufacturer and model with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Device Profiles Having Manufacturer Honeywell And Model ABC123
    ...                                   With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET010 - Query device resource by non-existent resourceName
    Given Generate A Device Profile Sample  Test-Profile-2
    And Create Device Profile ${deviceProfile}
    When Run Keyword And Expect Error  *  Query Device Resource By resourceName And profileName  Non-Existent  Test-Profile-2
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  Test-Profile-2

ErrProfileGET011 - Query device resource by non-existent profileName
    When Run Keyword And Expect Error  *  Query Device Resource By resourceName And profileName  DeviceValue_UINT16_RW  Non-Existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
