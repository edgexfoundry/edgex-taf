*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource         TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource         TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                             AND  Create device  create_device.json
Suite Teardown   Run keywords   Delete device by name Test-Device
...                             AND  Run Teardown Keywords

*** Variables ***
${SUITE}         Clean Up Events/Readings By Scheduler

*** Test Cases ***
Scheduler001-Set scheduler for each 30s to clean up events
    [Tags]  SmokeTest
    Given Create Interval and set frequency to "30"s
    And Create interval action with interval "30"s delete events for core-data
    And Create events by get device command
    When sleep  30s
    Then Query device events after exeucting deletion, and no event found
    [Teardown]  run keywords  Delete intervalAction by name "delete_events_30s"
    ...                       AND  Delete interval by name "frequency_30s"

Scheduler002-Set scheduler for each 60s to clean up events
    Given Create Interval and set frequency to "60"s
    And Create interval action with interval "60"s delete events for core-data
    And Create events by get device command
    When sleep  60s
    Then Query device events after exeucting deletion, and no event found
    [Teardown]  run keywords  Delete intervalAction by name "delete_events_60s"
    ...                       AND  Delete interval by name "frequency_60s"


*** Keywords ***
Create Interval and set frequency to "${interval_time}"s
    ${interval_frequency}=  Load data file "support-scheduler/interval.json" and get variable "interval_frequency"
    ${interval_frequency_str}=  convert to string  ${interval_frequency}
    ${interval_delete_replace_qoute}=  replace string    ${interval_frequency_str}   '   \"
    ${interval_frequency}=  replace string  ${interval_delete_replace_qoute}  %interval_time%  ${interval_time}
    Create interval  ${interval_frequency}
    Should return status code "200"

Create interval action with interval "${interval_time}"s delete events for core-data
    ${interval_delete_events}=  Load data file "support-scheduler/interval_action.json" and get variable "interval_delete_events"
    ${interval_delete_events_str}=  convert to string  ${interval_delete_events}
    ${interval_delete_replace_qoute}=  replace string    ${interval_delete_events_str}   '   \"
    ${delete_events_replace_interval_time}=  replace string  ${interval_delete_replace_qoute}  %interval_time%  ${interval_time}
    ${delete_events}=  replace string  ${delete_events_replace_interval_time}  "%CORE_DATA_PORT%"  48080
    Create intervalAction  ${delete_events}
    Should return status code "200"

Get random command and skip write only data
    @{data_type_skip_write_only}=  Skip write only commands
    ${random_command}=  Get random "commandName" from "${data_type_skip_write_only}"
    [Return]  ${random_command}

Create events by get device command
    FOR  ${INDEX}  IN RANGE  0  5
          ${random_command}=  Get random command and skip write only data
          Invoke Get command by device id "${device_id}" and command name "${random_command}"
    END
    ${status_code}  ${response_content}   Query events
    should be equal as integers  ${status_code}  200
    ${events_length}=   GET LENGTH  ${response_content}
    run keyword if  ${events_length} <= 3  fail  Events didn't create before clean up

Query device events after exeucting deletion, and no event found
    ${status_code}  ${response_content}   Query events
    should be equal as integers  ${status_code}  200
    ${events_length}=   GET LENGTH  ${response_content}
    run keyword if  ${events_length} > 3  fail  Found events after executing deletion

