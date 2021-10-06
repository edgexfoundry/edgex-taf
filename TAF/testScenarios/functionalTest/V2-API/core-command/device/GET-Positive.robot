*** Settings ***
Library         TAF/testCaseModules/keywords/setup/edgex.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource        TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup     Run Keywords  Setup Suite
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Command GET Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-get-positive.log
@{REST_DEVICES}    sample-image  sample-json  sample-numeric

*** Test Cases ***
CommandGET001 - Query all DeviceCoreCommands
    Given Create 5 Devices For device-virtual
    When Query All DeviceCoreCommands
    Then Should Return Status Code "200" And deviceCoreCommands
    And Should Be True  len(${content}[deviceCoreCommands]) == 8  # 3 for device-rest
    And All deviceCoreCommands Should Contain parameters In Each coreCommand
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete multiple devices by names  @{device_list}

CommandGET002 - Query all DeviceCoreCommands by offset
    Given Create 5 Devices For device-virtual
    When Query All DeviceCoreCommands With offset=2
    Then Should Return Status Code "200" And deviceCoreCommands
    And Should Be True  len(${content}[deviceCoreCommands]) == 6  # 3 for device-rest
    And All deviceCoreCommands Should Contain parameters In Each coreCommand
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete multiple devices by names  @{device_list}

CommandGET003 - Query all DeviceCoreCommands by limit
    Given Create 5 Devices For device-virtual
    When Query All DeviceCoreCommands With limit=3
    Then Should Return Status Code "200" And deviceCoreCommands
    And Should Be True  len(${content}[deviceCoreCommands]) == 3
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

CommandGET006 - Get specified device read command when ds-returnevent is no
    ${device_name}  Set Variable  Random-Boolean-Device
    Given Create Device For device-virtual With Name ${device_name}
    When Get Device ${device_name} Read Command Virtual_GenerateDeviceValue_Boolean_R With ds-returnevent=no
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

CommandGET007 - Get specified device read command when ds-pushevent is yes
    ${device_name}  Set Variable  Random-Float-Device
    Given Create Device For device-virtual With Name ${device_name}
    When Get Device ${device_name} Read Command Virtual_GenerateDeviceValue_FLOAT32_R With ds-pushevent=yes
    Then Should Return Status Code "200" And event
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Has Been Pushed To Core Data
    [Teardown]  Delete device by name ${device_name}

*** Keywords ***
Event Has Been Pushed To Core Data
    ${id}=  Set Variable  ${content}[event][id]
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataEventUri}/id/${id}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}
    Should Be True  "${content}[event][deviceName]" == "Random-Float-Device"

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

Create ${number} Devices For ${SERVICE_NAME}
    ${device_list}  Create List
    FOR  ${INDEX}  IN RANGE  0  ${number}
        ${name}  Set Variable  Command-Device-${INDEX}
        Create Device For ${SERVICE_NAME} With Name ${name}
        Append To List  ${device_list}  ${name}
    END
    Set Test Variable  ${device_list}  ${device_list}

