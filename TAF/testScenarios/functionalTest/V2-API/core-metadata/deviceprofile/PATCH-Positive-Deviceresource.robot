*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile PATCH Deviceresource Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-deviceresource-positive.log

*** Test Cases ***
ProfileResourcePATCH001 - Update deviceResource on one device profile
    Given Create A Device Profile with device resource
    When Update deviceResource
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceResource Should Be Updated
    [Teardown]  Delete Device Profile By Name

ProfileResourcePATCH002 - Update multiple deviceResources on one device profile
    Given Create a device profile with multiple device resources
    When Update deviceResource
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceResource Should Be Updated
    [Teardown]  Delete Device Profile By Name

ProfileResourcePATCH003 - Update multiple deviceResources on multiple device profiles
    Given Create multiple device profiles with multiple device resources
    When Update deviceResource
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceResource Should Be Updated
    [Teardown]  Delete Multiple Device Profiles By Names
