*** Settings ***
Library         TAF/testCaseModules/keywords/setup/edgex.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource        TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup     Run Keywords  Setup Suite
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core-Command GET Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-get-positive.log
@{REST_DEVICES}    sample-image  sample-json  sample-numeric

*** Test Cases ***
CommandGET001 - Query all DeviceCoreCommands
    Given Create 5 Devices For device-virtual
    When Query All DeviceCoreCommands
    Then Should Return Status Code "200" And deviceCoreCommands
    And totalCount Is Greater Than Zero And ${content}[deviceCoreCommands] Count Should Match totalCount
    And All deviceCoreCommands Should Contain parameters In Each coreCommand
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete multiple devices by names  @{device_list}

CommandGET002 - Query all DeviceCoreCommands by offset
    Given Create 5 Devices For device-virtual
    And Set Test Variable  ${offset}  2
    When Query All DeviceCoreCommands With offset=${offset}
    Then Should Return Status Code "200" And deviceCoreCommands
    And totalCount Is Greater Than Zero And ${content}[deviceCoreCommands] Count Should Match totalCount-offset
    And All deviceCoreCommands Should Contain parameters In Each coreCommand
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete multiple devices by names  @{device_list}

CommandGET003 - Query all DeviceCoreCommands by limit
    Given Create 5 Devices For device-virtual
    And Set Test Variable  ${limit}  3
    When Query All DeviceCoreCommands With limit=${limit}
    Then Should Return Status Code "200" And deviceCoreCommands
    And totalCount Is Greater Than Zero And ${content}[deviceCoreCommands] Count Should Match limit
    And All deviceCoreCommands Should Contain parameters In Each coreCommand
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete multiple devices by names  @{device_list}

CommandGET004 - Query DeviceCoreCommand by device name
    ${device_name}  Set Variable  Random-Integer-Device
    Given Create Device For device-virtual With Name ${device_name}
    When Query DeviceCoreCommands By Device Name  ${device_name}
    Then Should Return Status Code "200" And deviceCoreCommand
    And Should Be True  "${content}[deviceCoreCommand][deviceName]" == "${device_name}"
    And Each coreCommand Should Contain parameters  ${content}[deviceCoreCommand]
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

CommandGET005 - Get specified device read command
    ${device_name}  Set Variable  Random-Binary-Device
    ${source_name}  Set Variable  Virtual_GenerateDeviceValue_Binary_R
    Given Create Device For device-virtual With Name ${device_name}
    When Get Specified Device ${device_name} Read Command ${source_name}
    Then Should Return Status Code "200" And event
    And Should Be True  "${content}[event][deviceName]" == "${device_name}"
    And Should Be True  "${content}[event][sourceName]" == "${source_name}"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

CommandGET006 - Get specified device read command when ds-returnevent is false
    ${device_name}  Set Variable  Random-Boolean-Device
    Given Create Device For device-virtual With Name ${device_name}
    When Get Device ${device_name} Read Command Virtual_GenerateDeviceValue_Boolean_R With ds-returnevent=false
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

CommandGET007 - Get specified device read command when ds-pushevent is true
    Given Set Test Variable  ${device_name}  Random-Float-Device
    And Create Device For device-virtual With Name ${device_name}
    When Get Device ${device_name} Read Command Virtual_GenerateDeviceValue_FLOAT32_R With ds-pushevent=true
    Then Should Return Status Code "200" And event
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Has Been Pushed To Core Data
    [Teardown]  Delete device by name ${device_name}

CommandGET008 - Get specified device read command which command name contains Chinese and space character
    Given Set Test Variable  ${device_name}  Test-Device
    And Set Test Variable  ${test_command_url}  %E4%B8%AD%E6%96%87%E6%B5%8B%E8%AF%95%E8%B5%84%E6%BA%90%20UINT16  # 中文测试资源 UINT16
    And Create A Device Sample With Associated device-virtual And Test-Profile-5
    When Get Device ${device_name} Read Command ${test_command_url} With ds-pushevent=true
    Then Should Return Status Code "200" And event
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Has Been Pushed To Core Data
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Delete Device Profile By Name  Test-Profile-5

*** Keywords ***
Event Has Been Pushed To Core Data
    ${id}=  Set Variable  ${content}[event][id]
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${eventUri}/id/${id}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}
    Should Be True  "${content}[event][deviceName]" == "${device_name}"

All deviceCoreCommands Should Contain parameters In Each coreCommand
    ${deivceCoreCommands}=  Set Variable  ${content}[deviceCoreCommands]
    log  ${deivceCoreCommands}
    FOR  ${item}  IN  @{deivceCoreCommands}
        Run Keyword If  "${item}[deviceName]" not in "${REST_DEVICES}"
        ...             Each coreCommand should contain parameters  ${item}
    END

Each coreCommand Should Contain parameters
    [Arguments]  ${deviceCoreCommand}
    ${coreCommands}=  Set Variable  ${deviceCoreCommand}[coreCommands]
    Run Keyword If  "${deviceCoreCommand}[deviceName]" not in "${REST_DEVICES}"
    ...             Command Contains Parameters  ${coreCommands}

Command Contains Parameters
    [Arguments]  ${coreCommands}
    FOR  ${command}  IN  @{coreCommands}
        Dictionary Should Contain Key  ${command}  parameters
    END

Create Device For
    ${device}  Set device values  ${SERVICE_NAME}  ${PREFIX}-Sample-Profile
    Set To Dictionary  ${device}  name=${name}
    Generate Devices  ${device}
    Create Device With ${Device}
    sleep  500ms
    Set Test Variable  ${device_name}  ${name}
