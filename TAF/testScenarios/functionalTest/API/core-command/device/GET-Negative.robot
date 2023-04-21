*** Settings ***
Library         TAF/testCaseModules/keywords/setup/edgex.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup     Run Keywords  Setup Suite
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core-Command GET Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-get-negative.log

*** Test Cases ***
ErrCommandGET001 - Query all DeviceCoreCommands with non-int value on offset
    When Run Keyword And Expect Error  *  Query All DeviceCoreCommands With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET002 - Query all DeviceCoreCommands with invalid offset range
    When Run Keyword And Expect Error  *  Query All DeviceCoreCommands With offset=8
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET003 - Query all DeviceCoreCommands with non-int value on limit
    When Run Keyword And Expect Error  *  Query All DeviceCoreCommands With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET004 - Query DeviceCoreCommand with non-existent device name
    When Run Keyword And Expect Error  *  Query DeviceCoreCommand By Device Name  Non-Existent
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET005 - Get non-existent device read command
    When Run Keyword And Expect Error  *  Get Specified Device Non-Existent-Device Read Command Binary
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET006 - Get specified device non-existent read command
    When Run Keyword And Expect Error  *  Get Specified Device Random-Integer-Device Read Command Non-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET007 - Get specified device read command with invalid ds-returnevent
    When Run Keyword And Expect Error  *  Get Device Random-UnsignedInteger-Device Read Command Uint8 With ds-returnevent=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET008 - Get specified device read command with invalid ds-pushevent
    When Run Keyword And Expect Error  *  Get Device Random-Float-Device Read Command Float32 With ds-pushevent=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET009 - Get specified device read command when device AdminState is locked
    ${device_name}  Set Variable  Random-Boolean-Device
    Given Create Device For device-virtual With Name ${device_name}
    And Update Device ${device_name} With adminState=LOCKED
    When Run Keyword And Expect Error  *  Get Specified Device Random-Boolean-Device Read Command BoolArray
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

ErrCommandGET010 - Get specified device read command when device OperatingState is down
    ${device_name}  Set Variable  Random-Binary-Device
    Given Create Device For device-virtual With Name ${device_name}
    And Update Device ${device_name} With operatingState=DOWN
    When Run Keyword And Expect Error  *  Get Specified Device Random-Binary-Device Read Command Binary
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

ErrCommandGET011 - Get unavailable HTTP device read command
    # device-onvif-camera
    ${default_response_time_threshold}  Set Variable  8000    # normally exceed default 1200ms
    Given Set Test Variable  ${device_name}  Camera01
    And Set Test Variable  ${resource_name}  NetworkConfiguration
    And Create Device For device-onvif-camera With Name ${device_name}
    When Run Keyword And Expect Error  *  Get Specified Device ${device_name} Read Command ${resource_name}
    And Should Return Status Code "500" or "503"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

ErrCommandGET012 - Get unavailable Modbus device read command
    # device-modbus
    Given Set Test Variable  ${device_name}  Modbus-Test-Device
    And Create Unavailable Modbus device
    When Run Keyword And Expect Error  *  Get Specified Device ${device_name} Read Command Modbus_DeviceValue_Boolean_R
    And Should Return Status Code "500" or "503"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

*** Keywords ***
Should Return Status Code "500" or "503"
    Should Match Regexp  "${response}"  (500|503)
