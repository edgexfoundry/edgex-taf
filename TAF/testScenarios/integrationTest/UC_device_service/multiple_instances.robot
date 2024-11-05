*** Settings ***
Documentation  Multiple Instances
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Delete all events by age
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}              Multiple Instances

*** Test Cases ***
MultiInstance001 - Set and Get Command For 2 device-modbus both should be correct
    Given Prepare Test Data
    And Create Devices
    When Set Command For devices
    Then Get Command For Devices And Received Correct Values
    [Teardown]  Delete multiple devices by names  @{device_list}

MultiInstance002 - Change device-service of device and validate set/get command correctly
    Given Set Test Variable  ${PREFIX}  Modbus
    And Set Test Variable  ${device_name}  modbus_device
    And Create Device For device-modbus With Name ${device_name}
    And Set And Get Command For Device ${device_name} Should Be Correct
    When Update device-service To device-modbus_1 For Device ${device_name}
    Then Set And Get Command For Device ${device_name} Should Be Correct
    [Teardown]  Delete Device By Name ${device_name}

*** Keywords ***
Prepare Test Data
    Set Test Variable  ${PREFIX}  Modbus
    ${device_service_list}  Create List  device-modbus  device-modbus_1
    ${device_list}  Create List  device_1  device_2
    ${set_data}  Create Dictionary  Modbus_DeviceValue_INT16_RW=-999
    ${set_data_1}  Create Dictionary  Modbus_DeviceValue_UINT16_RW=32
    ${body_list}  Create List  ${set_data}  ${set_data_1}
    ${command_list}  Create List  Modbus_GenerateDeviceValue_INT16_RW  Modbus_GenerateDeviceValue_UINT16_RW
    Set Test Variable  ${device_service_list}  ${device_service_list}
    Set Test Variable  ${device_list}  ${device_list}
    Set Test Variable  ${command_list}  ${command_list}
    Set Test Variable  ${body_list}  ${body_list}

Create Devices
    FOR  ${service}  ${device}  IN ZIP  ${device_service_list}  ${device_list}
        Create Device For ${service} With Name ${device}
    END

Set Command For Devices
    FOR  ${device}  ${command}  ${body}  IN ZIP  ${device_list}  ${command_list}  ${body_list}
        Set specified device ${device} write command ${command} with ${body}
    END

Get Command For Devices And Received Correct Values
    FOR  ${device}  ${command}  ${data}  IN ZIP  ${device_list}  ${command_list}  ${body_list}
        ${value}  Get Dictionary Values  ${data}
        Get Specified Device ${device} Read Command ${command}
        Should Be True  "${content}[event][readings][0][value]" == "${value}[0]"
    END

Set And Get Command For Device ${device} Should Be Correct
    ${command}  Set Variable  Modbus_GenerateDeviceValue_INT16_RW
    ${body}  Create Dictionary  Modbus_DeviceValue_INT16_RW=32
    # Set Command
    Set specified device ${device} write command ${command} with ${body}
    # Get Command
    ${value}  Get Dictionary Values  ${body}
    Get Specified Device ${device} Read Command ${command}
    Should Be True  "${content}[event][readings][0][value]" == "${value}[0]"

Update device-service to ${service} for device ${device}
    ${body}  Create Dictionary  name=${device}  device-service=${service}
    Generate Devices  ${body}
    Update Devices ${device}
