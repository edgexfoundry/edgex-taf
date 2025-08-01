*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Profile DELETE DeviceCommand Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-delete-devicecommand-positive.log

*** Test Cases ***
ProfileCommandDELETE001 - Delete deviceCommand on one device profile with deviceCommand
    Given Set Test Variable  ${profile_name}  Test-Profile-1
    And Generate A Device Profile Sample  ${profile_name}
    And Create device profile ${deviceProfile}
    When Delete deviceCommand
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Command ${command_name} In ${profile_name} Should Be Deleted
    [Teardown]  Delete device profile by name  ${profile_name}

ProfileCommandDELETE002 - Delete deviceCommand by name which contains Chinese and space character
    Given Set Test Variable  ${test_profile}  Test-Profile-5
    And Set Test Variable  ${test_command}  中文测试命令 UINT16
    And Set Test Variable  ${test_command_url}  %E4%B8%AD%E6%96%87%E6%B5%8B%E8%AF%95%E5%91%BD%E4%BB%A4%20UINT16
    And Generate A Device Profile Sample  ${test_profile}
    And Create device profile ${deviceProfile}
    When Delete deviceCommand by Name ${test_command_url} in ${test_profile}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Command ${test_command} In ${test_profile} Should Be Deleted
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileCommandDELETE001 - Delete deviceCommand by non-existent profile name
    # non-existent profile name
    When Delete deviceCommand by Name CurrentStatus in Test-Profile-1
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileCommandDELETE002 - Delete deviceCommand by non-existent command name
    # non-existent deviceCommand name
    Given Set Test Variable  ${profile_name}  Test-Profile-1
    And Generate A Device Profile Sample  ${profile_name}
    And Create device profile ${deviceProfile}
    When Delete deviceCommand by Name non-existent in ${profile_name}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${profile_name}

ErrProfileCommandDELETE003 - Delete deviceCommand which profile used by device
    Given Set Test Variable  ${profile_name}  Test-Profile-2
    And Create A Device Sample With Associated device-virtual And ${profile_name}
    When Delete deviceCommand
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Command ${command_name} In ${profile_name} Should Not Be Deleted
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
     ...                  AND  Delete Device Service By Name  Test-Device-Service
     ...                  AND  Delete Device Profile By Name  ${profile_name}

ErrProfileCommandDELETE004 - Delete deviceCommand when StrictDeviceProfileChanges config is enabled
    # StrictDeviceProfileChanges config is true
    Given Set ProfileChange.StrictDeviceProfileChanges to true For Core-Metadata On Registry Service
    And Set Test Variable  ${profile_name}  Test-Profile-3
    And Generate A Device Profile Sample  ${profile_name}
    And Create device profile ${deviceProfile}
    When Delete deviceCommand
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Command ${command_name} In ${profile_name} Should Not Be Deleted
    [Teardown]  Run Keywords  Set ProfileChange.StrictDeviceProfileChanges to false For Core-Metadata On Registry Service
     ...                  AND  Delete Device Profile By Name  ${profile_name}

*** Keywords ***
Delete deviceCommand
    Query device profile by name  ${profile_name}
    ${commands}  Get All Device Command From Profile  ${content}
    ${command}  Evaluate  random.choice(@{commands})  random
    Delete deviceCommand by Name ${command} in ${profile_name}
    Set Test Variable  ${command_name}  ${command}

Get All Device Command From Profile
    [Arguments]  ${profile}
    ${commands}  Create List
    ${command_amount}  Get Length  ${profile}[profile][deviceCommands]
    FOR  ${INDEX}  IN RANGE  ${command_amount}
        ${name}  Set Variable  ${profile}[profile][deviceCommands][${INDEX}][name]
        Append To List  ${commands}  ${name}
    END
    RETURN  ${commands}

Device Command ${command_name} In ${profile} Should Be Deleted
    Query device profile by name  ${profile}
    ${commands}  Get All Device Command From Profile  ${content}
    List Should Not Contain Value  ${commands}  ${command_name}  The DeviceCommand is still existed

Device Command ${command_name} In ${profile} Should Not Be Deleted
    Query device profile by name  ${profile}
    ${commands}  Get All Device Command From Profile  ${content}
    List Should Contain Value  ${commands}  ${command_name}  The DeviceCommand is not existed
