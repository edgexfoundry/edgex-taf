*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource         TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource         TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown   Run Teardown Keywords
Force Tags       MessageBus=redis  DB=redis

*** Variables ***
${SUITE}         Clean Up Events/Readings By Scheduler

*** Test Cases ***
Scheduler001-Set scheduler for each 30s to clean up events
    [Tags]  SmokeTest
    Given Create Device For device-virtual With Name set-scheduler-30s-device
    And Create Interval and set interval value to 30s
    And Create interval action with interval delete events for core-data
    And Create events by get device command
    When sleep  30s
    Then Query device events after executing deletion, and no event found
    [Teardown]  run keywords  Delete intervalAction by name ${intervalAction_name}
    ...                       AND  Delete interval by name ${interval_name}
    ...                       AND  Delete device by name ${device_name}

Scheduler002-Set scheduler for each 60s to clean up events
    Given Create Device For device-virtual With Name set-scheduler-60s-device
    And Create Interval and set interval value to 60s
    And Create interval action with interval delete events for core-data
    And Create events by get device command
    When sleep  60s
    Then Query device events after executing deletion, and no event found
    [Teardown]  run keywords  Delete intervalAction by name ${intervalAction_name}
    ...                       AND  Delete interval by name ${interval_name}
    ...                       AND  Delete device by name ${device_name}


*** Keywords ***
Create Interval and set interval value to ${interval_time}
    General An Interval Sample
    Set To Dictionary  ${intervals}[0][interval]  interval=${interval_time}
    Create interval  ${intervals}
    Should Return Status Code "207"
    Item Index 0 Should Contain Status Code "201" And id

Create interval action with interval delete events for core-data
    General An IntervalAction Sample
    Set To Dictionary  ${intervalActions}[0][action]  intervalName=${interval_name}
    Set To Dictionary  ${intervalActions}[0][action][address]  host=edgex-core-data
    Set To Dictionary  ${intervalActions}[0][action][address]  path=${coreDataEventUri}/age/0
    Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'
    ...             Set To Dictionary  ${intervalActions}[0][action]  authmethod=JWT
    Create intervalAction  ${intervalActions}
    Should Return Status Code "207"
    Item Index 0 Should Contain Status Code "201" And id
