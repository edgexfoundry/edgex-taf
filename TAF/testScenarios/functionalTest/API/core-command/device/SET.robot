*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup     Run Keywords  Setup Suite
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core-Command Set Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-set.log

*** Test Cases ***
CommandSET001 - Set specified device write command
    [Tags]  SmokeTest
    ${set_data}=  Create Dictionary  Virtual_DeviceValue_INT8_RW=32
    ${device_name}  Set Variable  Random-Integer-Device
    Given Create Device For device-virtual With Name ${device_name}
    When Set Specified Device ${device_name} Write Command Virtual_GenerateDeviceValue_INT8_RW With ${set_data}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Command Virtual_DeviceValue_INT8_RW Vaule 32 On ${device_name} Have Been Updated
    [Teardown]  Delete device by name ${device_name}

CommandSET002 - Set specified device write command which command name contains Chinese and space character
    ${set_data}  Create Dictionary  中文測試資源 UINT32=1000000
    ${device_name}  Set Variable  Test-Device
    ${test_command_url}  Set Variable  %E4%B8%AD%E6%96%87%E6%B8%AC%E8%A9%A6%E5%91%BD%E4%BB%A4%20UINT32  #中文測試命令 UINT32
    ${test_resource_url}  Set Variable  %E4%B8%AD%E6%96%87%E6%B8%AC%E8%A9%A6%E8%B3%87%E6%BA%90%20UINT32  #中文測試資源 UINT32
    Given Create A Device Sample With Associated device-virtual And Test-Profile-5
    When Set Specified Device ${device_name} Write Command ${test_command_url} With ${set_data}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Command ${test_resource_url} Vaule 1000000 On ${device_name} Have Been Updated
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Delete Device Profile By Name  Test-Profile-5

ErrCommandSET001 - Set specified device write command with non-existent device
    ${set_data}=  Create Dictionary  Virtual_DeviceValue_INT8_W=32
    When Set Specified Device Non-existent-Device Write Command Virtual_GenerateDeviceValue_Boolean_W With ${set_data}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandSET002 - Set specified device write command with non-existent command
    ${device_name}  Set Variable  Random-Binary-Device
    Given Create Device For device-virtual With Name ${device_name}
    When Set Specified Device ${device_name} Write Command WriteBinary With &{EMPTY}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

ErrCommandSET003 - Set specified device write command when device is locked
    ${set_data}=  Create Dictionary  Virtual_DeviceValue_Boolean_W=99.2
    ${device_name}  Set Variable  Random-Float-Device
    Given Create Device For device-virtual With Name ${device_name}
    And Update Device ${device_name} With adminState=LOCKED
    When Set Specified Device ${device_name} Write Command Virtual_GenerateDeviceValue_FLOAT32_W With ${set_data}
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}


*** Keywords ***
Command ${command} Vaule ${value} On ${device} Have Been Updated
  Get Specified Device ${device} Read Command ${command}
  Should Be True  "${content}[event][readings][0][value]" == "${value}"
