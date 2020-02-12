*** Settings ***
Documentation  Device Readings - Scheduling
Library   OperatingSystem
Library   Collections
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup  Setup Suite


*** Variables ***
${SUITE}              Scheduling

*** Test Cases ***
Scheduling001 - Test Resource and Frequency for autoEvent
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