*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device PATCH Device Command Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-devicecommand-positive.log

*** Test Cases ***
ProfileCommandPATCH001 - Update one Command on device profile
    # one command > one profile
    Given Generate a profile and command sample for updating
    When Update command ${commandUpdate}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Profile Test-Profile-1 command isHidden Should Be ${false}
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ProfileCommandPATCH002 - Update multiple Command on multiple device profiles
    # multiple commands > multiple profiles
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Generate multiple command samples for updating
    When Update command ${commandUpdate}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Profile Test-Profile-1 command isHidden Should Be ${false}
    And Profile Test-Profile-2 command isHidden Should Be ${false}
    And Profile Test-Profile-3 command isHidden Should Be ${false}
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

*** Keywords ***
Generate multiple command samples for updating
    ${command_1}=  Create Dictionary  name=CurrentStatus  isHidden=${false}
    ${command_2}=  Create Dictionary  name=MotorKind   isHidden=${false}
    ${command_3}=  Create Dictionary  name=CurrentHumidity  isHidden=${false}
    Generate updating command  ${command_1}  ${command_2}  ${command_3}
    Set To Dictionary  ${commandUpdate}[0]  profileName=Test-Profile-1
    Set To Dictionary  ${commandUpdate}[1]  profileName=Test-Profile-2
    Set To Dictionary  ${commandUpdate}[2]  profileName=Test-Profile-3

Profile ${profile_name} command isHidden Should Be ${bool}
    Query device profile by name  ${profile_name}
    Should Be Equal  ${content}[profile][deviceCommands][0][isHidden]  ${bool}
