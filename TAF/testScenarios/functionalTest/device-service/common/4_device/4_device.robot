*** Settings ***
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/deviceServiceAPI.robot
Resource  TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup     Setup Suite


*** Variables ***
${SUITE}              Device

*** Test Cases ***
Device_TC0001a - Invoke GET command when device adminState is LOCKED
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    Given Create device  create_locked_device.json
    sleep  500ms
    When Invoke Get command by device id "${device_id}" and command name "${command_name}"
    Then Should return status code "423"
    [Teardown]  Delete device by name

Device_TC0001b - Invoke PUT command when device adminState is LOCKED
    [Tags]  Backward
    @{data_types_skip_write_only}=  Skip write only commands
    ${data_type}=     set variable  ${data_types_skip_write_only}[0][dataType]
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    ${reading_name}=     set variable  ${data_types_skip_write_only}[0][readingName]
    ${random_value}=    Get reading value with data type "${data_type}"
    ${set_reading_value}=   convert to string  ${random_value}
    Given Create device  create_locked_device.json
    sleep  500ms
    When Invoke Put command by device id "${device_id}" and command name "${command_name}" with request body "${reading_name}":"${set_reading_value}"
    Then Should return status code "423"
    [Teardown]  Delete device by name

Device_TC0002a - Invoke GET command when device operatingState is DISABLED
    [Tags]  Backward
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    Given Create device  create_disabled_device.json
     sleep  500ms
    When Invoke Get command by device id "${device_id}" and command name "${command_name}"
    Then Should return status code "423"
    [Teardown]  Delete device by name

Device_TC0002b - Invoke PUT command when device operatingState is DISABLED
    @{data_types_skip_write_only}=  Skip write only commands
    ${data_type}=     set variable  ${data_types_skip_write_only}[0][dataType]
    ${commandName}=     set variable  ${data_types_skip_write_only}[0][commandName]
    ${reading_name}=     set variable  ${data_types_skip_write_only}[0][readingName]
    ${random_value}=    Get reading value with data type "${data_type}"
    ${set_reading_value}=   convert to string  ${random_value}
    Given Create device  create_disabled_device.json
    sleep  500ms
    When Invoke Put command by device id "${device_id}" and command name "${command_name}" with request body "${reading_name}":"${set_reading_value}"
    Then Should return status code "423"
    [Teardown]  Delete device by name