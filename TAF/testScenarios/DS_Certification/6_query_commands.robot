*** Settings ***
Documentation  Device Readings - Query commands
Library   OperatingSystem
Library   Collections
Resource  ./keywords/coreMetadataAPI.robot
Resource  ./keywords/deviceVirtualAPI.robot
Resource  ./keywords/coreDataAPI.robot
Suite Setup   Create device profile and device
Suite Teardown   Delete device profile and device

*** Variables ***
${SUITE}              Query Commands

*** Test Cases ***
Test Retrieve device reading by id and the data is sent to Core Data with multiple data type
    @{data_types_skip_write_only}=  Skip write only commands
    : FOR    ${item}    IN    @{data_types_skip_write_only}
    \  run keyword and continue on failure  Retrieve device reading by id and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}

Test Retrieve device reading by id but the device does not exist
    @{data_types_skip_write_only}=  Skip write only commands
    ${commandName}=     set variable  ${data_types_skip_write_only}[0][commandName]
    Retrieve device reading by id but the device does not exist  ${commandName}

Test Retrieve device reading by id but the command does not exist
    ${deviceId}=    get environment variable  deviceId
    When Invoke Get command by device id "${deviceId}" and command name "invalid_command_name"
    Then DS should return status code "404"

Test Retrieve device reading by name and the data is sent to Core Data with multiple data type
     @{data_types_skip_write_only}=  Skip write only commands
    : FOR    ${item}    IN    @{data_types_skip_write_only}
    \  run keyword and continue on failure  Retrieve device reading by name and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}

Test Retrieve device reading by name but the device does not exist
    @{data_types_skip_write_only}=  Skip write only commands
    ${commandName}=     set variable  ${data_types_skip_write_only}[0][commandName]
    Retrieve device reading by id but the device does not exist  ${commandName}

Test Retrieve device reading by name but the command does not exist
    ${deviceName}=    Query device by id and return device name
    When Invoke Get command by device name "${deviceName}" and command name "Invalid command Name"
    Then DS should return status code "404"

Test Retrieve all devices data but the command does not exist
    When Invoke Get command name "invalid_command_name" for all devices
    Then DS should return status code "404"

*** Keywords ***
# Get commands by id /device/{id}/{command}
Retrieve device reading by id and the data is sent to Core Data
    [Arguments]      ${dataType}    ${commandName}    ${readingName}
    ${deviceId}=    get environment variable  deviceId
    When Invoke Get command by device id "${deviceId}" and command name "${commandName}"
    Then DS should return status code "200"
    And Value should be "${dataType}"
    And Device reading "${readingName}" should be sent to Core Data

Retrieve device reading by id but the device does not exist
    [Arguments]  ${commandName}
    When Invoke Get command by device id "12ab34cd-12ef-123e-123f-123456789d0c" and command name "${commandName}"
    Then DS should return status code "404"

# Get commands by name /device/{name}/{command}
Retrieve device reading by name and the data is sent to Core Data
    [Arguments]      ${dataType}    ${commandName}    ${readingName}
    ${deviceName}=    Query device by id and return device name
    When Invoke Get command by device name "${deviceName}" and command name "${commandName}"
    Then DS should return status code "200"
    And Value should be "${dataType}"
    And Device reading "${readingName}" should be sent to Core Data

Retrieve device reading by name but the device does not exist
    [Arguments]  ${commandName}
    When Invoke Get command by device name "Invalid device Name" and command name "${commandName}"
    Then DS should return status code "404"


# Get commands by all devices /device/all/{command}
# Test Retrieve all devices data and the data is sent to Core Data [Validation is still not complete]
#     [Setup]  Create device profile and device
#     When Invoke Get command name "${validGetCommandName}" for all devices
#     Then DS should return status code "200"
#     And Device reading should be sent to Core Data
#     [Teardown]  Delete device profile and device


Skip write only commands
    @{data_types_skip_write_only}=    Create List
    :FOR    ${item}    IN    @{SUPPORTED_DATA_TYPES}
    \     Continue For Loop If   '${item["readWrite"]}' == 'W'
    \     Append To List    ${data_types_skip_write_only}    ${item}
    [Return]   ${data_types_skip_write_only}

