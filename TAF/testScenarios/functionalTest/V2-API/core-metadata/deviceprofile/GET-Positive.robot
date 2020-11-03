*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-get-positive.log
${api_version}    v2

*** Test Cases ***
ProfileGET001 - Query all device profiles
    [Tags]  SmokeTest
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles
    Then Should Return Status Code "200" And profiles
    And Should Return Content-Type "application/json"
    And Should Be True  len(${content}[profiles]) == 3
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET002 - Query all device profiles by offset
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles With offset=2
    Then Should Return Status Code "200" And profiles
    And Should Return Content-Type "application/json"
    And Should Be True  len(${content}[profiles]) == 1
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET003 - Query all device profiles by limit
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles With limit=2
    Then Should Return Status Code "200" And profiles
    And Should Return Content-Type "application/json"
    And Should Be True  len(${content}[profiles]) == 2
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET004 - Query all device profiles by labels
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles With labels=bacnet
    Then Should Return Status Code "200" And profiles
    And Should Return Content-Type "application/json"
    And Should Be True  len(${content}[profiles]) == 2
    And Profiles Should Be Linked To Specified Labels: bacnet
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET005 - Query device profile by name
    [Tags]  SmokeTest
    Given Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    When Query Device Profile By Name  Test-Profile-1
    Then Should Return Status Code "200" And profile
    And Should Be True  "${content}[profile][name]" == "Test-Profile-1"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  Test-Profile-1

ProfileGET006 - Query device profiles by manufacturer
    # Multiple device profile which part of same manufacturer
    [Tags]  Skipped
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer
    And Validate Response Schema
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profiles

ProfileGET007 - Query device profiles by manufacturer and offset
    # Multiple device profile which part of same manufacturer
    [Tags]  Skipped
    Given Create Multiple Device Profiles
    When Query Device Profiles By Manufacturer
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer
    And Validate Response Schema
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profiles

ProfileGET008 - Query device profiles by manufacturer and limit
    # Multiple device profile which part of same manufacturer
    [Tags]  Skipped
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer
    And Validate Response Schema
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profiles

*** Keywords ***
Profiles Should Be Linked To Specified ${property}: ${value}
    ${profiles}=  Set Variable  ${content}[profiles]
    ${property}=  Convert To Lower Case  ${property}
    FOR  ${item}  IN  @{profiles}
        List Should Contain Value  ${item}[${property}]  ${value}
    END
