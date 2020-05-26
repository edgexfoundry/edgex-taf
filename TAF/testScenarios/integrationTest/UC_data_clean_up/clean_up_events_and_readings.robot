*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/deviceServiceAPI.robot
Resource         TAF/testCaseModules/keywords/coreDataAPI.robot
Resource         TAF/testCaseModules/keywords/supportSchedulerAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Deploy device service  device-virtual
...                             AND  Create device  create_device.json
Suite Teardown   Run keywords   Remove services  device-virtual
...                             AND  Delete device by name Test-Device
...                             AND  Delete device profile by name Sample-Profile

*** Variables ***
${SUITE}         Clean Up Events By Scheduler
${interval_frequency}
...  {
...    "name" : "frequency_%interval_time%s", "start": "20200101T000000", "frequency": "PT%interval_time%S"
...  }

${delete_events}
...  {
...    "name" :"delete_events_%interval_time%s","interval":"frequency_%interval_time%s","target":"core-data",
...    "protocol": "http", "httpMethod": "DELETE", "address": "edgex-core-data",
...    "path":"/api/v1/event/removeold/age/0", "port": ${CORE_DATA_PORT}
...  }


*** Variables ***
${SUITE}         Clean Up Events/Readings By Scheduler


*** Test Cases ***
Scheduler001-Set scheduler for each 30s to clean up events
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
    ${interval_frequency}=  replace string  ${interval_frequency}  %interval_time%  ${interval_time}
    Create interval  ${interval_frequency}
    Should return status code "200"

Create interval action with interval "${interval_time}"s delete events for core-data
    ${delete_events}=  replace string  ${delete_events}  %interval_time%  ${interval_time}
    Create intervalAction  ${delete_events}
    Should return status code "200"

Get random command and skip write only data
    @{data_type_skip_write_only}=  Skip write only commands
    ${random_command}=  Get random "commandName" from "${data_type_skip_write_only}"
    [Return]  ${random_command}

Create events by get device command
    :FOR  ${INDEX}  IN RANGE  0  5
    \     ${random_command}=  Get random command and skip write only data
    \     Invoke Get command by device id "${device_id}" and command name "${random_command}"
    ${status_code}  ${response_content}   Query events
    should be equal as integers  ${status_code}  200
    ${events_length}=   GET LENGTH  ${response_content}
    run keyword if  ${events_length} <= 3  fail  Events didn't create before clean up

Query device events after exeucting deletion, and no event found
    ${status_code}  ${response_content}   Query events
    should be equal as integers  ${status_code}  200
    ${events_length}=   GET LENGTH  ${response_content}
    run keyword if  ${events_length} > 3  fail  Found events after executing deletion

