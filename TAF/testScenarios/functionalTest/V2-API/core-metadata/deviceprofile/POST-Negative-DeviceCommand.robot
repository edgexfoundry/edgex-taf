*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Device Command Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-devicecommand-negative.log

*** Test Cases ***
ErrProfileCommandPOST001 - Add deviceCommand with Empty profile name
    # Empty profile name
    Given Generate deviceCommand
    And Set To Dictionary  ${commandProfile}[0]  profileName=${EMPTY}
    When Create New command ${commandProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileCommandPOST002 - Add deviceCommand with Non-existent profile name
    # Non-existent profile name
    Given Generate deviceCommand
    And Set To Dictionary  ${commandProfile}[0]  profileName=non-existent
    When Create New command ${commandProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileCommandPOST003 - Add deviceCommand with Duplicate command name
    # 2 device command with same command name
    Given Generate a device profile and Add multiple Commands on device profile
    And Create New Command ${commandProfile}
    When Create New Command ${commandProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ErrProfileCommandPOST004 - Add deviceCommand with Empty Command name
    # deviceCommands > deviceCommand without name
    # Contains valid profile body
    Given Generate a device profile and Add multiple Commands on device profile
    And Set To Dictionary  ${commandProfile}[0][deviceCommand]  name=${EMPTY}
    When Create New Command ${commandProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ErrProfileCommandPOST005- Add deviceCommand with Empty readWrite
    # deviceCommands > deviceCommand without readWrite
    # Contains valid profile body
    Given Generate a device profile and Add multiple Commands on device profile
    And Set To Dictionary  ${commandProfile}[0][deviceCommand]  readWrite=${EMPTY}
    When Create New Command ${commandProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ErrProfileCommandPOST006- Add deviceCommand with Invalid readWrite
    # deviceCommands > deviceCommand invalid readWrite
    # Contains valid profile body
    Given Generate a device profile and Add multiple Commands on device profile
    And Set To Dictionary  ${commandProfile}[0][deviceCommand]  readWrite=invalid
    When Create New Command ${commandProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ErrProfileCommandPOST007 - Add deviceCommand with Empty deviceResource
    # deviceCommand > resourceOperations without deviceResource
    # Contains valid profile body
    Given Generate a device profile and Add multiple Commands on device profile
    And Set To Dictionary  ${commandProfile}[0][deviceCommand][resourceOperations][0]  deviceResource=${EMPTY}
    When Create New Command ${commandProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ErrProfileCommandPOST008 - Add deviceCommand with Non-existent deviceResource
    # deviceCommand > resourceOperations Non-existent deviceResource
    # Contains valid profile body
    Given Generate a device profile and Add multiple Commands on device profile
    And Set To Dictionary  ${commandProfile}[0][deviceCommand][resourceOperations][0]  deviceResource=invalid
    When Create New Command ${commandProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${test_profile}

*** Keywords ***
Generate deviceCommand
    ${command_data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/command_profile.json  encoding=UTF-8
    ${json_string}=  Evaluate  json.loads(r'''${command_data}''')  json
    Generate command  ${json_string}
