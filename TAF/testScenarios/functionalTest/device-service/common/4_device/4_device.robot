*** Settings ***
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}              Verify adminState and operatingState
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/device-sdk-command.log

*** Test Cases ***
Device_TC0001a - Invoke GET command when device adminState is LOCKED
    Given Get A Read Command
    And Create Device Locked-Device And Set adminState To LOCKED
    When Invoke Get command by device Locked-Device and command ${command}
    Then Should return status code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name Locked-Device

Device_TC0001b - Invoke SET command when device adminState is LOCKED
    Given Get A Read Command
    And Create Device Locked-Device And Set adminState To LOCKED
    When Invoke SET command by device Locked-Device and command ${command} with request body ${reading_name}:${set_reading_value}
    Then Should return status code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name Locked-Device

Device_TC0002a - Invoke GET command when device operatingState is DOWN
    Given Get A Read Command
    And Create Device Down-Device And Set operatingState To DOWN
    When Invoke Get command by device Down-Device and command ${command}
    Then Should return status code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name Down-Device

Device_TC0002b - Invoke SET command when device operatingState is DISABLED
    Given Get A Read Command
    And Create Device Down-Device And Set operatingState To DOWN
    When Invoke SET command by device Down-Device and command ${command} with request body ${reading_name}:${set_reading_value}
    Then Should return status code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device by name Down-Device

*** Keywords ***
Create Device ${name} And Set ${field} To ${field_value}
    ${device}=  Set device values  ${SERVICE_NAME}  ${PREFIX}-Sample-Profile
    Set To Dictionary  ${device}  name=${name}
    Set To Dictionary  ${device}  ${field}=${field_value}
    Generate Devices  ${device}
    Create Device With ${Device}
    sleep  500ms
