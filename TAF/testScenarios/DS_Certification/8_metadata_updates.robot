*** Settings ***
Documentation  Device Readings - Actuation commands
Library   Collections
Resource  ./keywords/coreMetadataAPI.robot
Resource  ./keywords/deviceServiceAPI.robot
Resource  ./keywords/commonKeywords.robot


*** Variables ***
${SUITE}        Actuation Commands
${int8Value}    5


*** Test Cases ***
Test Callback API Post method is available
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    #Given Create device profile
    When Create device  create_device.json
    ${device_id}=  get environment variable  deviceId
    Then Invoke Get command by device id "${device_id}" and command name "${commandName}"
    And Should return status code "200"
    [Teardown]  Delete device by name

Test Callback API Post method with invalid action type
    When Invoke Post callback for the device "1234-5678-12345-67890" with action type "invalid_action_type"
    Then Should return status code "400"

Test Callback API Delete method is available
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    #Given Create device profile
    Given Create device  create_device.json
    ${device_id}=    get environment variable  deviceId
    When Invoke Delete callback for the device "${device_id}" with action type "DEVICE"
    Then Invoke Get command by device id "${device_id}" and command name "${commandName}"
    And Should return status code "404"
    [Teardown]  Delete device by name

Test Callback API Delete method with invalid action type
    #Given Create device profile
    Given Create device  create_device.json
    ${device_id}=    get environment variable  deviceId
    When Invoke Delete callback for the device "${device_id}" with action type "invalid_action_type"
    Then Should return status code "400"
    [Teardown]  Delete device by name
