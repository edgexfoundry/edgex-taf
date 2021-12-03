*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-get-positive-ll.log

*** Test Cases ***
ProfileGET009 - Query device profiles by manufacturer's model
    # Multiple device profile which part of same manufacturer and same model
    Given Create Multiple Device Profiles Sample With Different Device Info
    When Query All Device Profiles By Manufacturer And Model  Honeywell  ABC123
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount
    And Profiles Should Be Linked To Specified Manufacturer: Honeywell
    And Profiles Should Be Linked To Specified Model: ABC123
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles Sample With Different Device Info

ProfileGET010 - Query device profiles by manufacturer's model and offset
    # Multiple device profile which part of same manufacturer and same model
    Given Create Multiple Device Profiles Sample With Different Device Info
    And Set Test Variable  ${offset}  1
    When Query All Device Profiles Having Manufacturer Honeywell And Model ABC123 With offset=${offset}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount-offset
    And Profiles Should Be Linked To Specified Manufacturer: Honeywell
    And Profiles Should Be Linked To Specified Model: ABC123
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles Sample With Different Device Info

ProfileGET011 - Query device profiles by manufacturer's model and limit
    # Multiple device profile which part of same manufacturer and same model
    Given Create Multiple Device Profiles Sample With Different Device Info
    And Set Test Variable  ${limit}  1
    When Query All Device Profiles Having Manufacturer Honeywell And Model ABC123 With limit=${limit}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match limit
    And Profiles Should Be Linked To Specified Manufacturer: Honeywell
    And Profiles Should Be Linked To Specified Model: ABC123
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles Sample With Different Device Info

ProfileGET012 - Query device profiles by model
    # Multiple device profile with different manufacturer but same model
    Given Create Multiple Device Profiles Sample With Different Device Info
    When Query All Device Profiles By Model  ABC123
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount
    And Profiles Should Be Linked To Specified Model: ABC123
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles Sample With Different Device Info

ProfileGET013 - Query device profiles by model and offset
    # Multiple device profile with different manufacturer but same model
    Given Create Multiple Device Profiles Sample With Different Device Info
    And Set Test Variable  ${offset}  1
    When Query All Device Profiles By Model ABC123 With offset=1
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount-offset
    And Profiles Should Be Linked To Specified Model: ABC123
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles Sample With Different Device Info

ProfileGET014 - Query device profiles by model and limit
    # Multiple device profile with different manufacturer but same model
    Given Create Multiple Device Profiles Sample With Different Device Info
    And Set Test Variable  ${limit}  1
    When Query All Device Profiles By Model ABC123 With limit=${limit}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match limit
    And Profiles Should Be Linked To Specified Model: ABC123
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles Sample With Different Device Info

ProfileGET015 - Query device profiles by empty manufacturer value
    # Multiple device profile which part of same manufacturer and same model
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[0][profile]  manufacturer=${EMPTY}
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles By Manufacturer  Honeywell
    Then Should Return Status Code "200" And profiles
    And totalCount Should be 2
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET016 - Query device profiles by empty model value
    # Multiple device profile which part of same manufacturer and same model
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[0][profile]  model=${EMPTY}
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles By Model  ABC123
    Then Should Return Status Code "200" And profiles
    And totalCount Should be 2
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileGET017 - Query device resource by resourceName and profileName
    Given Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    When Query Device Resource By resourceName And profileName  DeviceValue_Boolean_RW  Test-Profile-1
    Then Should Return Status Code "200" And resource
    And Should Be True  "${content}[resource][name]" == "DeviceValue_Boolean_RW"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  Test-Profile-1

*** Keywords ***
Create Multiple Device Profiles Sample With Different Device Info
    Generate Multiple Device Profiles Sample
    # Test-Profile-1: Not_Honeywell and Not_ABC123
    Set To Dictionary  ${deviceProfile}[0][profile]  manufacturer=Not_Honeywell
    Set To Dictionary  ${deviceProfile}[0][profile]  model=Not_ABC123
    Create Device Profile ${deviceProfile}
    Generate Multiple Device Profiles Sample
    Set To Dictionary  ${deviceProfile}[0][profile]  name=New-Profile-1
    # New-Profile-2: Not_Honeywell and ABC123
    Set To Dictionary  ${deviceProfile}[1][profile]  name=New-Profile-2
    Set To Dictionary  ${deviceProfile}[1][profile]  manufacturer=Not_Honeywell
    # New-Profile-3: Honeywell and Not_ABC123
    Set To Dictionary  ${deviceProfile}[2][profile]  name=New-Profile-3
    Set To Dictionary  ${deviceProfile}[2][profile]  model=Not_ABC123
    Create Device Profile ${deviceProfile}

Delete Multiple Device Profiles Sample With Different Device Info
    Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
    ...                                       New-Profile-1  New-Profile-2  New-Profile-3

Profiles Should Be Linked To Specified ${property}: ${value}
    # property: model, manufacturer
    ${profiles}=  Set Variable  ${content}[profiles]
    ${property}=  Convert To Lower Case  ${property}
    FOR  ${item}  IN  @{profiles}
        Should Be Equal As Strings  ${item}[${property}]  ${value}
    END

