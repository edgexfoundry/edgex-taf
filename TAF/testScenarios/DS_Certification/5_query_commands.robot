*** Settings ***
Documentation  Device Readings - Query commands
Library   OperatingSystem
Library   Collections
Resource  ./keywords/coreMetadataAPI.robot
Resource  ./keywords/deviceServiceAPI.robot
Resource  ./keywords/coreDataAPI.robot
Resource  ./keywords/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite  AND  Create device  create_device.json
Suite Teardown  Delete device by name

*** Variables ***
${SUITE}              Query Commands

*** Test Cases ***
Test Retrieve device reading by id and the data is sent to Core Data with multiple data type
    @{data_types_skip_write_only}=  Skip write only commands
    : FOR    ${item}    IN    @{data_types_skip_write_only}
    \  run keyword and continue on failure  Retrieve reading by device id and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}

Test Retrieve device reading by id but the device does not exist
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    Retrieve reading by device id but the device does not exist  ${command_name}

Test Retrieve device reading by id but the command does not exist
    ${device_id}=    get environment variable  deviceId
    When Invoke Get command by device id "${device_id}" and command name "invalid_command_name"
    Then Should return status code "404"

Test Retrieve device reading by name and the data is sent to Core Data with multiple data type
     @{data_types_skip_write_only}=  Skip write only commands
    : FOR    ${item}    IN    @{data_types_skip_write_only}
    \  run keyword and continue on failure  Retrieve reading by device name and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}

Test Retrieve device reading by name but the device does not exist
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    Retrieve reading by device name but the device does not exist  ${command_name}

Test Retrieve device reading by name but the command does not exist
    ${device_name}=    Query device by id and return device name
    When Invoke Get command by device name "${device_name}" and command name "Invalid command Name"
    Then Should return status code "404"

Test Retrieve all devices data and the data is sent to Core Data
    @{data_types_skip_write_only}=  Skip write only commands
    : FOR    ${item}    IN    @{data_types_skip_write_only}
    \  run keyword and continue on failure  Retrieve all devices data and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}

Test Retrieve all devices data but the command does not exist
    When Invoke Get command name "invalid_command_name" for all devices
    Then Should return status code "404"

*** Keywords ***
# Get commands by id /device/{id}/{command}
Retrieve reading by device id and the data is sent to Core Data
    [Arguments]      ${dataType}    ${command_name}    ${reading_name}
    ${device_id}=    get environment variable  deviceId
    ${start_time}=  Get milliseconds epoch time
    ${end_time}=  evaluate  ${start_time}+2000
    sleep  1s
    When Invoke Get command by device id "${device_id}" and command name "${command_name}"
    Then Should return status code "200"
    And Value should be "${dataType}"
    And Query device reading by start/end time  ${start_time}  ${end_time}

Retrieve reading by device id but the device does not exist
    [Arguments]  ${command_name}
    When Invoke Get command by device id "12ab34cd-12ef-123e-123f-123456789d0c" and command name "${command_name}"
    Then Should return status code "404"

# Get commands by name /device/{name}/{command}
Retrieve reading by device name and the data is sent to Core Data
    [Arguments]      ${dataType}    ${command_name}    ${reading_name}
    ${device_name}=    Query device by id and return device name
    ${start_time}=  Get milliseconds epoch time
    ${end_time}=  evaluate  ${start_time}+2000
    sleep  1s
    When Invoke Get command by device name "${device_name}" and command name "${command_name}"
    Then Should return status code "200"
    And Value should be "${dataType}"
    And Query device reading by start/end time  ${start_time}  ${end_time}

Retrieve reading by device name but the device does not exist
    [Arguments]  ${command_name}
    When Invoke Get command by device name "Invalid device Name" and command name "${command_name}"
    Then Should return status code "404"


# Get commands by all devices /device/all/{command}
Retrieve all devices data and the data is sent to Core Data
    [Arguments]  ${dataType}    ${command_name}    ${reading_name}
    ${start_time}=  Get milliseconds epoch time
    ${end_time}=  evaluate  ${start_time}+2000
    sleep  1s
    ${responseBody}=  Invoke Get command name "${command_name}" for all devices
    ${response_length}=  get length  ${responseBody}
    run keyword if  ${response_length} >=5  fail  "No device reading found"
    :FOR    ${response}    IN    @{responseBody}
    \     ${readings_length}=  get length  ${response}[readings]
    \     run keyword if  ${readings_length} == 0   fail  "No readings found:"+ ${response}[device]
    \     Query device reading by start/end time  ${start_time}  ${end_time}
