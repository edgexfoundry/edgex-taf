*** Settings ***
Documentation  Device Readings - Actuation commands
Library   Collections
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/deviceServiceAPI.robot
Resource  TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup     Setup Suite


*** Variables ***
${SUITE}        Metadata Update


*** Test Cases ***
Callback001 - Test Callback API Post method is available
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    #Given Create device profile
    When Create device  create_device.json
    sleep  500ms
    Then Invoke Get command by device id "${device_id}" and command name "${commandName}"
    And Should return status code "200"
    [Teardown]  Delete device by name

Callback002 - Test Callback API Post method with invalid action type
    When Invoke Post callback for the device "1234-5678-12345-67890" with action type "invalid_action_type"
    Then Should return status code "400"

Callback003 - Test Callback API Delete method is available
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    #Given Create device profile
    Given Create device  create_device.json
    sleep  500ms
    ${device_id_str}=  convert to string  ${device_id}
    When Invoke Delete callback for the device "${device_id_str}" with action type "DEVICE"
    sleep  500ms
    Then Invoke Get command by device id "${device_id}" and command name "${commandName}"
    And Should return status code "404"
    [Teardown]  Delete device by name

Callback004 - Test Callback API Delete method with invalid action type
    #Given Create device profile
    Given Create device  create_device.json
    ${device_id_str}=  convert to string  ${device_id}
    When Invoke Delete callback for the device "${device_id_str}" with action type "invalid_action_type"
    Then Should return status code "400"
    [Teardown]  Delete device by name
