*** Settings ***
Documentation  Device Readings - Query commands
Library   OperatingSystem
Library   Collections
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource  TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}              Query Commands

*** Test Cases ***
Get001 - Test Retrieve device reading by name and the data is sent to Core Data with multiple data type
    Get A Read Command
    Create Device For ${SERVICE_NAME} With Name Query-Command-Device
    FOR    ${item}    IN    @{data_types_skip_write_only}
      run keyword and continue on failure  Retrieve reading by device name and the data is sent to Core Data  ${item["dataType"]}  ${item["commandName"]}  ${item["readingName"]}
    END
    [Teardown]  Delete device by name ${device_name}

ErrGet001 - Test Retrieve device reading by name but the device does not exist
    Given Get A Read Command
    When Invoke Get command by device Invalid-device-Name and command ${command}
    Then Should return status code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrGet002 - Test Retrieve device reading by name but the command does not exist
    Given Create Device For ${SERVICE_NAME} With Name Invalid-Command-Device
    When Invoke Get command by device ${device_name} and command Invalid-Command
    Then Should return status code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

ErrGet003 - Test Retrieve device reading by name but the command is write only
    Given Get A Write Only Command
    And Create Device For ${SERVICE_NAME} With Name Write-Command-Device
    When Invoke Get command by device ${device_name} and command ${command}
    Then Should return status code "405"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

*** Keywords ***
# Get commands by name /device/{name}/{command}
Retrieve reading by device name and the data is sent to Core Data
    [Arguments]    ${dataType}    ${command_name}    ${reading_name}
    ${start_time}=  Get current milliseconds epoch time
    When Invoke Get command with params ds-pushevent=true by device ${device_name} and command ${command_name}
    Then Should return status code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Value should be "${dataType}"
    sleep  500ms
    ${end_time}=  Get current milliseconds epoch time
    And Query readings by start/end time  ${start_time}  ${end_time}

Get A Write Only Command
    @{data_types_write_only}  Get All Write Only Commands
    ${data_type}  set variable  ${data_types_write_only}[0][dataType]
    ${command}  set variable  ${data_types_write_only}[0][commandName]
    ${reading_name}  set variable  ${data_types_write_only}[0][readingName]
    ${random_value}  Get reading value with data type "${data_type}"
    ${set_reading_value}  convert to string  ${random_value}
    Set Test Variable  ${data_types_write_only}  ${data_types_write_only}
    Set Test Variable  ${command}  ${command}
    Set Test Variable  ${reading_name}  ${reading_name}
    Set Test Variable  ${set_reading_value}  ${set_reading_value}


