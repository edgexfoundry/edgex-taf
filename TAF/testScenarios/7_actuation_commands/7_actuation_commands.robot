*** Settings ***
Documentation  Device Readings - Actuation commands
Library   Collections
Resource  TAF/testCaseApps/keywords/coreMetadataAPI.robot
Resource  TAF/testCaseApps/keywords/deviceServiceAPI.robot
Resource  TAF/testCaseApps/keywords/coreDataAPI.robot
Resource  TAF/testCaseApps/keywords/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite  AND  Create device  create_device.json
Suite Teardown  Delete device by name

*** Variables ***
${SUITE}        Actuation Commands


*** Test Cases ***
# Actuation commands by id /device/{id}/{command}
PUT001 - Test DS actuates commands to device/sensor by id on multiple data type
    @{data_types_get_rw}=  Skip read only and write only commands "${SUPPORTED_DATA_TYPES}"
    : FOR    ${item}    IN    @{data_types_get_rw}
    \   run keyword and continue on failure   DS actuates commands to device/sensor by id  ${item["dataType"]}   ${item["commandName"]}  ${item["readingName"]}

PUT002 - Test DS actuates commands to device/sensor by id with invalid request body
    @{data_types_skip_read_only}=  Skip read only commands
    ${command_name}=     set variable  ${data_types_skip_read_only}[0][commandName]
    ${reading_name}=     set variable  ${data_types_skip_read_only}[0][readingName]
    DS actuates commands to device/sensor by id with invalid request body  ${command_name}   ${reading_name}

PUT003 - Test DS actuates commands to device/sensor by id with invalid device
    @{data_types_skip_read_only}=  Skip read only commands
    ${data_type}=     set variable  ${data_types_skip_read_only}[0][dataType]
    ${command_name}=     set variable  ${data_types_skip_read_only}[0][commandName]
    ${reading_name}=     set variable  ${data_types_skip_read_only}[0][readingName]
    DS actuates commands to device/sensor by id with invalid device  ${data_type}   ${command_name}   ${reading_name}

PUT004 - Test DS actuates commands to device/sensor by id with invalid command
    @{data_types_skip_read_only}=  Skip read only commands
    ${data_type}=     set variable  ${data_types_skip_read_only}[0][dataType]
    ${reading_name}=     set variable  ${data_types_skip_read_only}[0][readingName]
    DS actuates commands to device/sensor by id with invalid command  ${data_type}   ${reading_name}

# Actuation commands by name /device/name/{name}/{command}
PUT005 - Test DS actuates commands to device/sensor by name on multiple data type
    @{data_types_get_rw}=  Skip read only and write only commands "${SUPPORTED_DATA_TYPES}"
    : FOR    ${item}    IN    @{data_types_get_rw}
    \   run keyword and continue on failure   DS actuates commands to device/sensor by name  ${item["dataType"]}   ${item["commandName"]}  ${item["readingName"]}

PUT006 - Test DS actuates commands to device/sensor by name with invalid request body
    @{data_types_skip_read_only}=  Skip read only commands
    ${command_name}=     set variable  ${data_types_skip_read_only}[0][commandName]
    ${reading_name}=     set variable  ${data_types_skip_read_only}[0][readingName]
    DS actuates commands to device/sensor by name with invalid request body  ${command_name}   ${reading_name}

PUT007 - Test DS actuates commands to device/sensor by name with invalid device
    @{data_types_skip_read_only}=  Skip read only commands
    ${data_type}=     set variable  ${data_types_skip_read_only}[0][dataType]
    ${command_name}=     set variable  ${data_types_skip_read_only}[0][commandName]
    ${reading_name}=     set variable  ${data_types_skip_read_only}[0][readingName]
    DS actuates commands to device/sensor by name with invalid device  ${data_type}    ${command_name}   ${reading_name}

PUT008 - Test DS actuates commands to device/sensor by name with invalid command
    @{data_types_skip_read_only}=  Skip read only commands
    ${data_type}=     set variable  ${data_types_skip_read_only}[0][dataType]
    ${reading_name}=     set variable  ${data_types_skip_read_only}[0][readingName]
    DS actuates commands to device/sensor by name with invalid command  ${data_type}    ${reading_name}


*** Keywords ***
# Actuation commands by id /device/{id}/{command}
DS actuates commands to device/sensor by id
    [Arguments]      ${data_type}   ${command_name}    ${reading_name}
    ${device_id}=    get environment variable  deviceId
    ${random_value}=    Get reading value with data type "${data_type}"
    ${reading_value}=   convert to string  ${random_value}
    When Invoke Put command by device id "${device_id}" and command name "${command_name}" with request body "${reading_name}":"${reading_value}"
    Then Should return status code "200"
    And Invoke Get command by device id "${deviceId}" and command name "${commandName}"
    And Device reading should be sent to Core Data   ${data_type}  ${reading_name}  ${reading_value}

DS actuates commands to device/sensor by id with invalid request body
    [Arguments]      ${command_name}    ${reading_name}
    ${device_id}=    get environment variable  deviceId
    When Invoke Put command by device id "${device_id}" and command name "${command_name}" with request body "${reading_name}":"invalid data value"
    Then Should return status code "400"

DS actuates commands to device/sensor by id with invalid device
    [Arguments]      ${data_type}    ${command_name}    ${reading_name}
    ${random_value}=    Get reading value with data type "${data_type}"
    ${reading_value}=   convert to string  ${random_value}
    When Invoke Put command by device id "af91c740-4aeac-435d-8720-5f95dd1584ef" and command name "${command_name}" with request body "${reading_name}":"${reading_value}"
    Then Should return status code "404"

DS actuates commands to device/sensor by id with invalid command
    [Arguments]   ${data_type}    ${reading_name}
    ${device_id}=    get environment variable  deviceId
    ${random_value}=    Get reading value with data type "${data_type}"
    ${reading_value}=   convert to string  ${random_value}
    When Invoke Put command by device id "${device_id}" and command name "invalid_command_name" with request body "${reading_name}":"${reading_value}"
    Then Should return status code "404"

# Actuation commands by name /device/name/{name}/{command}
DS actuates commands to device/sensor by name
    [Arguments]    ${data_type}      ${command_name}    ${reading_name}
    ${device_name}=    Query device by id and return device name
    ${random_value}=    Get reading value with data type "${data_type}"
    ${reading_value}=   convert to string  ${random_value}
    When Invoke Put command by device name "${device_name}" and command name "${command_name}" with request body "${reading_name}":"${reading_value}"
    Then Should return status code "200"
    And Invoke Get command by device name "${deviceName}" and command name "${commandName}"
    And Device reading should be sent to Core Data   ${data_type}   ${reading_name}  ${reading_value}

DS actuates commands to device/sensor by name with invalid request body
    [Arguments]    ${command_name}    ${reading_name}
    ${device_name}=    Query device by id and return device name
    When Invoke Put command by device name "${device_name}" and command name "${command_name}" with request body "${reading_name}":"invalid data value"
    Then Should return status code "400"

DS actuates commands to device/sensor by name with invalid device
    [Arguments]    ${data_type}    ${command_name}    ${reading_name}
    ${random_value}=    Get reading value with data type "${data_type}"
    ${reading_value}=   convert to string  ${random_value}
    When Invoke Put command by device name "invalid_device" and command name "${command_name}" with request body "${reading_name}":"${reading_value}"
    Then Should return status code "404"

DS actuates commands to device/sensor by name with invalid command
    [Arguments]   ${data_type}    ${reading_name}
    ${device_name}=    Query device by id and return device name
    ${random_value}=    Get reading value with data type "${data_type}"
    ${reading_value}=   convert to string  ${random_value}
    When Invoke Put command by device name "${device_name}" and command name "invalid_command_name" with request body "${reading_name}":"${reading_value}"
    Then Should return status code "404"
