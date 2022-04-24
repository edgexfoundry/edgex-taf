*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device PATCH Device Command Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-devicecommand-positive.log

*** Test Cases ***
ProfileCommandPATCH001 - Update deviceCommand on one device profile
    Given Create A Device Profile with deviceCommand
    When Update deviceCommand
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceCommand Should Be Updated
    [Teardown]  Delete Device Profile By Name

ProfileCommandPATCH002 - Update multiple deviceCommands on one device profile
    Given Create a device profile with multiple deviceCommands
    When Update deviceCommand
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceCommand Should Be Updated
    [Teardown]  Delete Device Profile By Name

ProfileCommandPATCH003 - Update multiple deviceCommand on multiple device profiles
    Given Create multiple device profiles with multiple deviceCommands
    When Update deviceCommand
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceCommand Should Be Updated
     [Teardown]  Delete Multiple Device Profiles By Names


