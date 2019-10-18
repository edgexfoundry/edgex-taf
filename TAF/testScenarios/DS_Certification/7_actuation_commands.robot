*** Settings ***
Documentation  Device Readings - Actuation commands
Library   Collections
Resource  ./keywords/coreMetadataAPI.robot
Resource  ./keywords/deviceVirtualAPI.robot
Resource  ./keywords/coreDataAPI.robot
Suite Setup  Create device profile and device
Suite Teardown  Delete device profile and device

*** Variables ***
${SUITE}        Actuation Commands
${int8Value}    5


*** Test Cases ***
Test DS actuates commands to device/sensor by id on multiple data type
    @{data_types_skip_read_only}=  Skip read only commands
    : FOR    ${item}    IN    @{data_types_skip_read_only}
    \   run keyword and continue on failure   DS actuates commands to device/sensor by id  ${item["commandName"]}  ${item["readingName"]}

Test DS actuates commands to device/sensor by id with invalid request body
    @{data_types_skip_read_only}=  Skip read only commands
    ${commandName}=     set variable  ${data_types_skip_read_only}[0][commandName]
    DS actuates commands to device/sensor by id with invalid request body  ${commandName}

Test DS actuates commands to device/sensor by id with invalid device
    @{data_types_skip_read_only}=  Skip read only commands
    ${commandName}=     set variable  ${data_types_skip_read_only}[0][commandName]
    ${readingName}=     set variable  ${data_types_skip_read_only}[0][readingName]
    DS actuates commands to device/sensor by id with invalid device  ${commandName}   ${readingName}

Test DS actuates commands to device/sensor by id with invalid command
    @{data_types_skip_read_only}=  Skip read only commands
    ${readingName}=     set variable  ${data_types_skip_read_only}[0][readingName]
    DS actuates commands to device/sensor by id with invalid command  ${readingName}

*** Keywords ***
# Actuation commands by id /device/{id}/{command}
DS actuates commands to device/sensor by id
    [Arguments]      ${putCommandName}    ${readingName}
    ${deviceId}=    get environment variable  deviceId
    When Invoke Put command by device id "${deviceId}" and command name "${putCommandName}" with request body "${readingName}":"${int8Value}"
    Then DS should return status code "200"
    And Device reading "${readingName}" should be sent to Core Data

DS actuates commands to device/sensor by id with invalid request body
    [Arguments]      ${putCommandName}
    ${deviceId}=    get environment variable  deviceId
    When Invoke Put command by device id "${deviceId}" and command name "${putCommandName}" with request body "invalid_reading_name":"${int8Value}"
    Then DS should return status code "400"

DS actuates commands to device/sensor by id with invalid device
    [Arguments]      ${putCommandName}    ${readingName}
    When Invoke Put command by device id "af91c740-4aeac-435d-8720-5f95dd1584ef" and command name "${putCommandName}" with request body "${readingName}":"${int8Value}"
    Then DS should return status code "404"

DS actuates commands to device/sensor by id with invalid command
    [Arguments]   ${readingName}
    ${deviceId}=    get environment variable  deviceId
    When Invoke Put command by device id "${deviceId}" and command name "invalid_command_name" with request body "${readingName}":"${int8Value}"
    Then DS should return status code "404"

Skip read only commands
    @{data_types_skip_read_only}=    Create List
    :FOR    ${item}    IN    @{SUPPORTED_DATA_TYPES}
    \     Continue For Loop If   '${item["readWrite"]}' == 'R'
    \     Append To List    ${data_types_skip_read_only}    ${item}
    [Return]  ${data_types_skip_read_only}