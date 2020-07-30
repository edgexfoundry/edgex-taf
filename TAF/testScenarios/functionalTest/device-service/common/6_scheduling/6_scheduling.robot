*** Settings ***
Documentation  Device Readings - Scheduling
Library   OperatingSystem
Library   Collections
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token

*** Variables ***
${SUITE}              Scheduling

*** Test Cases ***
Scheduling001 - Test Resource and Frequency for autoEvent
    [Tags]  Backward
    @{data_types_skip_write_only}=  Skip write only commands
    ${last_reading}=  Get last support reading
    ${reading_name}=     set variable  ${data_types_skip_write_only}[${last_reading}][readingName]
    ${frequency_value}=  set variable  8
    ${onChange_value}=  set variable  false
    When Creat device with autoEvents parameter    ${frequency_value}  ${onChange_value}  ${reading_name}
    Then Device autoEvents with "${reading_name}" send by frequency setting "${frequency_value}"s
    [Teardown]  Delete device by name


*** Keywords ***
Get last support reading
    @{data_types_skip_write_only}=  Skip write only commands
    ${support_data_length}=  get length  ${data_types_skip_write_only}
    ${last_reading}=  evaluate   ${support_data_length}-1
    [Return]   ${last_reading}