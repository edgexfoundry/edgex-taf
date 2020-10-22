*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-get-negative.log
${api_version}    v2

*** Test Cases ***
ErrProfileGET001 - Query device profile by non-existent name
    When Run Keyword And Expect Error  *  Query Device Profile By Name  Non-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET002 - Query device profiles by empty manufacturer value
    [Tags]  Skipped
    When Query Device Profile By Manufacturer
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET003 - Query device profiles by existed manufacturer and empty model value
    [Tags]  Skipped
    When Query Device Profile By Manufacturer And Model
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET004 - Query device profiles by empty model value
    [Tags]  Skipped
    When Query Device Profile By Model
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET005 - Query all device profile with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Device Profiles With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileGET005 - Query all device profile with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Device Profiles With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
