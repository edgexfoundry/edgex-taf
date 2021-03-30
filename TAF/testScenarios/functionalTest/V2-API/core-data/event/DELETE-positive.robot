*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Event DELETE Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-delete-positive.log
${api_version}    v2

*** Test Cases ***
EventDELETE001 - Delete event by ID
    Given Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  Simple Reading  Simple Float Reading
    And Create Event With Device-Test-001 And Profile-Test-001 And Command-Test-001
    And Set Test Variable  ${id}  ${content}[id]
    When Delete Event By ID  ${id}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Be Deleted  ${id}

EventDELETE002 - Delete events with specified device by device name
    Given Create Multiple Events
    When Delete Events By Device Name  Device-Test-001
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Events With Specified Device Should Be Deleted
    [Teardown]  Delete All Events By Age

EventDELETE003 - Delete all old events (and associated readings) based on delimiting age
    Given Create Multiple Events For Deleting By Age
    When Delete all events by age  ${age}
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Old Events Should Be Deleted
    [Teardown]  Delete All Events By Age


*** Keywords ***
Event Should Be Deleted
  [Arguments]  ${event_id}
  Query event by event id "${event_id}"
  Should Be Equal As Integers  ${response}  404

Events With Specified Device Should Be Deleted
  Query All Events
  ${count}=  Get Length  ${content}[events]
  Should Be Equal As Integers  ${count}  3
  FOR  ${index}  IN RANGE  0  3
    Should Not Be Equal  ${content}[events][${index}][deviceName]  Device-Test-001
  END

Create Multiple Events For Deleting By Age
  Create Multiple Events
  ${before_time}=  Get current nanoseconds epoch time
  Create Multiple Events
  ${after_time}=  Get current nanoseconds epoch time
  ${age}=  Evaluate  ${after_time} - ${before_time}
  Set Test Variable  ${age}  ${age}

Old Events Should Be Deleted
  Query All Events Count
  Should Be Equal As Integers  ${content}[Count]  6
