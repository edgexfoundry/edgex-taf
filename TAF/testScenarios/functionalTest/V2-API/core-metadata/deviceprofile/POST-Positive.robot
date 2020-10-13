*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-positive.log
${api_version}    v2

*** Test Cases ***
ProfilePOST001 - Create device profile with json body
    Given Generate Multiple Device Profiles Sample
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfilePOST002 - Create device profile by upload file
    When Upload Device Profile Test-Profile-4.yaml
    Then Should Return Status Code "201"
    And Should Return Content-Type "application/json"
    And Should Contain "id"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  Test-Profile-4

