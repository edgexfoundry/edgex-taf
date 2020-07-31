*** Settings ***
Documentation  Device Readings - Query commands
Library   OperatingSystem
Library   Collections
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource  TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Create device  create_device.json
Suite Teardown  Run Keywords  Delete device by name
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token

*** Variables ***
${SUITE}              Query Commands

*** Test Cases ***
Get001 - Test Retrieve device reading by id and the data is sent to Core Data with multiple data type
    [Tags]  Backward
    @{data_types_skip_write_only}=  Skip write only commands
    FOR    ${item}    IN    @{data_types_skip_write_only}
       run keyword and continue on failure  Retrieve reading by device id and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}
    END

Get002 - Test Retrieve device reading by id but the device does not exist
    [Tags]  Backward
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    Retrieve reading by device id but the device does not exist  ${command_name}

Get003 - Test Retrieve device reading by id but the command does not exist
    When Invoke Get command by device id "${device_id}" and command name "invalid_command_name"
    Then Should return status code "404"

Get004 - Test Retrieve device reading by name and the data is sent to Core Data with multiple data type
    [Tags]  Backward
    @{data_types_skip_write_only}=  Skip write only commands
    FOR    ${item}    IN    @{data_types_skip_write_only}
      run keyword and continue on failure  Retrieve reading by device name and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}
    END

Get005 - Test Retrieve device reading by name but the device does not exist
    @{data_types_skip_write_only}=  Skip write only commands
    ${command_name}=     set variable  ${data_types_skip_write_only}[0][commandName]
    Retrieve reading by device name but the device does not exist  ${command_name}

Get006 - Test Retrieve device reading by name but the command does not exist
    ${device_name}=    Query device by id and return device name
    When Invoke Get command by device name "${device_name}" and command name "Invalid command Name"
    Then Should return status code "404"

Get007 - Test Retrieve all devices data and the data is sent to Core Data
    @{data_types_skip_write_only}=  Skip write only commands
    FOR    ${item}    IN    @{data_types_skip_write_only}
       run keyword and continue on failure  Retrieve all devices data and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}
    END

Get008 - Test Retrieve all devices data but the command does not exist
    When Invoke Get command name "invalid_command_name" for all devices
    Then Should return status code "404"

*** Keywords ***
# Get commands by id /device/{id}/{command}
Retrieve reading by device id and the data is sent to Core Data
    [Arguments]      ${dataType}    ${command_name}    ${reading_name}
    ${start_time}=  Get current milliseconds epoch time
    When Invoke Get command by device id "${device_id}" and command name "${command_name}"
    Then Should return status code "200"
    And Value should be "${dataType}"
    sleep  500ms
    ${end_time}=  Get current milliseconds epoch time
    And Query device reading by start/end time  ${start_time}  ${end_time}

Retrieve reading by device id but the device does not exist
    [Arguments]  ${command_name}
    When Invoke Get command by device id "12ab34cd-12ef-123e-123f-123456789d0c" and command name "${command_name}"
    Then Should return status code "404"

# Get commands by name /device/{name}/{command}
Retrieve reading by device name and the data is sent to Core Data
    [Arguments]      ${dataType}    ${command_name}    ${reading_name}
    ${device_name}=    Query device by id and return device name
    ${start_time}=  Get current milliseconds epoch time
    When Invoke Get command by device name "${device_name}" and command name "${command_name}"
    Then Should return status code "200"
    And Value should be "${dataType}"
    sleep  500ms
    ${end_time}=  Get current milliseconds epoch time
    And Query device reading by start/end time  ${start_time}  ${end_time}

Retrieve reading by device name but the device does not exist
    [Arguments]  ${command_name}
    When Invoke Get command by device name "Invalid device Name" and command name "${command_name}"
    Then Should return status code "404"


# Get commands by all devices /device/all/{command}
Retrieve all devices data and the data is sent to Core Data
    [Arguments]  ${dataType}    ${command_name}    ${reading_name}
    ${start_time}=  Get current milliseconds epoch time
    ${responseBody}=  Invoke Get command name "${command_name}" for all devices
    ${response_length}=  get length  ${responseBody}
    run keyword if  ${response_length} >=5  fail  "No device reading found"
    FOR    ${response}    IN    @{responseBody}
          ${readings_length}=  get length  ${response}[readings]
          sleep  500ms
          ${end_time}=  Get current milliseconds epoch time
          run keyword if  ${readings_length} == 0   fail  "No readings found:"+ ${response}[device]
          Query device reading by start/end time  ${start_time}  ${end_time}
    END
