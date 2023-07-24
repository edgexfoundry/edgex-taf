*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Device Command Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-devicecommand-positive.log

*** Test Cases ***
ProfileCommandPOST001 - Add multiple Commands on device profile
    # multiple commands > one profile
    Given Generate a device profile and Add multiple commands on device profile
    When Create New command ${commandProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New Command Switch in Test-Profile-1 Should Be Added
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ProfileCommandPOST002 - Add multiple Commands on multiple device profiles
    # multiple Commands > multiple profiles
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Add multiple Commands on multiple device profile
    When Create New Command ${commandProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New Command Switch in Test-Profile-1 Should Be Added
    And New Command GetSensorValues in Test-Profile-2 Should Be Added
    And New Command Speed in Test-Profile-3 Should Be Added
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileCommandPOST003 - Add Commands with Chinese and space character in command name
    Given Set Test Variable  ${test_profile}  Test-Profile-3
    And Set Test Variable  ${test_resource}  中文资源名称 String
    And Set Test Variable  ${test_command}  中文命令名称 String
    And Upload Device Profile ${test_profile}.yaml
    And Create Device Resource With Resource Name ${test_resource} To ${test_profile}
    When Create Device Command With Command Name ${test_command} To ${test_profile}
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "201"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New Command ${test_command} in ${test_profile} Should Be Added
    [Teardown]  Delete Device Profile By Name  ${test_profile}

*** Keywords ***
New Command ${command_name} in ${profile_name} Should Be Added
    Query device profile by name  ${profile_name}
    ${command_name_list}  Create List
    FOR  ${command}  IN  @{content}[profile][deviceCommands]
            Append To List  ${command_name_list}  ${command}[name]
    END
    List Should Contain Value  ${command_name_list}  ${command_name}

Create Device Command With Command Name ${command_name} To ${profile_name}
    ${command_data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/command_profile.json  encoding=UTF-8
    ${commandProfile}=  Evaluate  json.loads(r'''${command_data}''')  json
    ${new_commandProfile}  Get Slice From List  ${commandProfile}  0  1
    Set To Dictionary  ${new_commandProfile}[0]  apiVersion=${API_VERSION}
    Set To Dictionary  ${new_commandProfile}[0]  profileName=${profile_name}
    Set To Dictionary  ${new_commandProfile}[0][deviceCommand]  name=${command_name}
    Set To Dictionary  ${new_commandProfile}[0][deviceCommand][resourceOperations][0]  deviceResource=${test_resource}
    Create New Command ${new_commandProfile}
