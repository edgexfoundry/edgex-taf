*** Settings ***
Documentation  Device Readings - Scheduling
Library   OperatingSystem
Library   Collections
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}              Scheduling

*** Test Cases ***
Scheduling001 - Test Resource and Interval for autoEvent
    @{data_types_all_read}  Get All Read Commands
    ${last_reading}  Get last support reading
    ${reading_name}  Set Variable  ${data_types_all_read}[${last_reading}][readingName]
    Given Set Test Variable  ${device_name}  autoevent-device
    When Create AutoEvent Device  8s  false  ${reading_name}
    Then Device autoEvents with ${reading_name} send by interval setting 8s
    [Teardown]  Delete device by name ${device_name}


*** Keywords ***
Get last support reading
    @{data_types_skip_write_only}=  Get All Read Commands
    ${support_data_length}=  get length  ${data_types_skip_write_only}
    ${last_reading}=  evaluate   ${support_data_length}-1
    RETURN   ${last_reading}

Device autoEvents with ${reading_name} send by interval setting ${interval_value}s
    ${sleep_time}=  evaluate  ${interval_value}
    ${start_time}=   Get current milliseconds epoch time
    # Sleep 2 seconds for first auto event of C DS because it will execute auto event after creating the device without schedule time
    sleep  2
    Run Keyword And Continue On Failure  Query readings by device name  ${device_name}
    ${init_device_reading_count}=  get length  ${content}[readings]
    FOR    ${INDEX}    IN RANGE  1  4
       sleep  ${sleep_time}s
       ${end_time}=   Get current milliseconds epoch time
       ${expected_device_reading_count}=  evaluate  ${init_device_reading_count} + ${INDEX}
       Run Keyword And Continue On Failure  Query readings by device name  ${device_name}
       ${device_reading_count}  get length  ${content}[readings]
       run keyword and continue on failure  should be equal as integers  ${expected_device_reading_count}  ${device_reading_count}
    END

