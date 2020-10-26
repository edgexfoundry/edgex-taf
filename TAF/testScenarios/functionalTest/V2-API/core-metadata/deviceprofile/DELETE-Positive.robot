*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile DELETE Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-delete-positive.log
${api_version}    v2

*** Test Cases ***
ProfileDELETE001 - Delete device profile by ID
    Given Generate A Device Profile Sample  Test-Profile-2
    And Create device profile ${deviceProfile}
    And Get "id" From Multi-status Item 0
    When Delete Device Profile By ID  ${item_value}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Profile Should Be Deleted  Test-Profile-2

ProfileDELETE002 - Delete device profile by name
    Given Generate A Device Profile Sample  Test-Profile-3
    And Create device profile ${deviceProfile}
    When Delete Device Profile By Name  Test-Profile-3
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Profile Should Be Deleted  Test-Profile-3

*** keywords ***
Device Profile Should Be Deleted
    [Arguments]  ${device_profile_name}
    Run Keyword And Expect Error  "*not found"  Query device profile by name  ${device_profile_name}
    Should Return Status Code "404"
