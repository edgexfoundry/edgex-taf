*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-get-positive.log

*** Test Cases ***
ProfileGET001 - Query all device profiles
    [Tags]  SmokeTest
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET002 - Query all device profiles by offset
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Set Test Variable  ${offset}  2
    When Query All Device Profiles With offset=${offset}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount-offset
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET003 - Query all device profiles by limit
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Set Test Variable  ${limit}  2
    When Query All Device Profiles With limit=${limit}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match limit
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET004 - Query all device profiles by labels
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles With labels=bacnet
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount
    And Profiles Should Be Linked To Specified Labels: bacnet
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET005 - Query device profile by name
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
    Given Create Multiple Device Profiles Sample With Different Manufacturers
    When Query All Device Profiles By Manufacturer  Honeywell
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount
    And Profiles Should Be Linked To Specified Manufacturer: Honeywell
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET007 - Query device profiles by manufacturer and offset
    # Multiple device profile which part of same manufacturer
    Given Create Multiple Device Profiles Sample With Different Manufacturers
    And Set Test Variable  ${offset}  1
    When Query All Device Profiles By Manufacturer Honeywell With offset=${offset}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount-offset
    And Profiles Should Be Linked To Specified Manufacturer: Honeywell
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET008 - Query device profiles by manufacturer and limit
    # Multiple device profile which part of same manufacturer
    Given Create Multiple Device Profiles Sample With Different Manufacturers
    And Set Test Variable  ${limit}  2
    When Query All Device Profiles By Manufacturer Honeywell With limit=${limit}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match limit
    And Profiles Should Be Linked To Specified Manufacturer: Honeywell
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

*** Keywords ***
Profiles Should Be Linked To Specified ${property}: ${value}
    ${profiles}=  Set Variable  ${content}[profiles]
    ${property}=  Convert To Lower Case  ${property}
    FOR  ${item}  IN  @{profiles}
        Run keyword if  "${property}" == "labels"  List Should Contain Value  ${item}[${property}]  ${value}
        ...    ELSE IF  "${property}" == "manufacturer"  Should Be Equal As Strings  ${item}[${property}]  ${value}
    END

Create Multiple Device Profiles Sample With Different Manufacturers
    Generate Multiple Device Profiles Sample
    Set To Dictionary  ${deviceProfile}[0][profile]  manufacturer=Not_Honeywell
    Create Device Profile ${deviceProfile}


