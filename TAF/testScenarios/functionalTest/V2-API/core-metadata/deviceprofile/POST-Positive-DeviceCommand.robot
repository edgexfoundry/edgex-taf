*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Device Command Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-devicecommand-positive.log

*** Test Cases ***
ProfileCommandPOST001 - Add deviceCommand on one device profile with deviceCommand
     # one command > one profile
    Given Create A Device Profile with deviceCommand
    When Add A New Command on device profile
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New Command Should Be Added
    [Teardown]  Delete Device Profile By Name

ProfileCommandPOST002 - Add multiple deviceCommands on one device profile basicinfo only
     # multiple commands >  one basicinfo profile
    Given Create A Device Profile with deviceCommand
    When Add Multiple New Commands on device profile
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New Command Should Be Added
    [Teardown]  Delete Device Profile By Name

ProfileCommandPOST003 - Add multiple deviceCommands on multiple device profiles
     # multiple commands > multiple basicinfo profiles & profiles sample
    Given Create Multiple Device Profiles Basicinfo Only
    And Create Multiple Device Profiles Sample
    When Add Multiple New Commands on Device Profiles Basicinfo Only
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New Command Should Be Added
    [Teardown]  Delete Multiple Device Profiles By Names
