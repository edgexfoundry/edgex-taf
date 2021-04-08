*** Settings ***
Documentation  Device Readings - Actuation commands
Library   Collections
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource  TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}        Actuation Commands


*** Test Cases ***
# Actuation commands by name /device/name/{name}/{command}
SET001 - Test DS actuates commands to device/sensor by name on multiple data type
    @{data_types_get_rw}  Skip read only and write only commands "${SUPPORTED_DATA_TYPES}"
    Create Device For ${SERVICE_NAME} With Name Update-Command-Device
    FOR    ${item}    IN    @{data_types_get_rw}
        run keyword and continue on failure   DS actuates commands to device/sensor by name  ${item["dataType"]}   ${item["commandName"]}  ${item["readingName"]}
    END
    [Teardown]  Delete device by name ${device_name}

ErrSET001 - Test DS actuates commands to device/sensor by name with invalid request body
    Given Get A Write Command
    And Create Device For ${SERVICE_NAME} With Name Update-Command-Device
    When Invoke SET command by device ${device_name} and command ${command} with request body ${reading_name}:invalid_value
    Then Should return status code "500"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}

ErrSET002 - Test DS actuates commands to device/sensor by name with invalid device
    Given Get A Write Command
    When Invoke SET command by device invalid_device and command ${command} with request body ${reading_name}:${reading_value}
    Then Should return status code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSET003 - Test DS actuates commands to device/sensor by name with invalid command
    Given Get A Write Command
    And Create Device For ${SERVICE_NAME} With Name Update-Command-Device
    When Invoke Set command by device ${device_name} and command invalid_command with request body ${reading_name}:${reading_value}
    Then Should return status code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name ${device_name}


*** Keywords ***
# Actuation commands by name /device/name/{name}/{command}
DS actuates commands to device/sensor by name
    [Arguments]    ${data_type}      ${command}    ${reading_name}
    ${random_value}  Get reading value with data type "${data_type}"
    ${set_reading_value}  convert to string  ${random_value}
    When Invoke SET command by device ${device_name} and command ${command} with request body ${reading_name}:${set_reading_value}
    Then Should return status code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

Get A Write Command
    @{data_types_all_write}  Get All Write Commands
    ${data_type}  set variable  ${data_types_all_write}[0][dataType]
    ${command}  set variable  ${data_types_all_write}[0][commandName]
    ${reading_name}  set variable  ${data_types_all_write}[0][readingName]
    ${random_value}  Get reading value with data type "${data_type}"
    ${reading_value}  convert to string  ${random_value}
    Set Test Variable  ${data_types_all_write}  ${data_types_all_write}
    Set Test Variable  ${command}  ${command}
    Set Test Variable  ${reading_name}  ${reading_name}
    Set Test Variable  ${reading_value}  ${reading_value}

