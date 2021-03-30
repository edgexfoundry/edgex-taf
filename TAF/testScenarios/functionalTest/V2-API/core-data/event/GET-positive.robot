*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Event GET Postive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-positive.log
${api_version}    v2

*** Test Cases ***
EventGET001 - Query all events
    Given Create Multiple Events
    When Query All Events
    Then Should Return Status Code "200"
    And Should Return All Events
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET002 - Query event by ID
    [Tags]  SmokeTest
    Given Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  Simple Reading
    And Create Event With Device-Test-001 And Profile-Test-001 And Command-Test-001
    When Query Event By Event Id "${id}"
    Then Should Return Status Code "200" And event
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET003 - Query all events with specified device by device name
    Given Create Multiple Events
    When Query Events By Device Name  Device-Test-001
    Then Should Return Status Code "200"
    And Events Should Be Linked To Specified Device
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET004 - Query events by start/end time
    Given Create Multiple Events Twice To Get Start/End Time
    When Query Events By Start/End Time  ${start_time}  ${end_time}
    Then Should Return Status Code "200"
    And Events Should Be Created Between ${start_time} And ${end_time}
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET005 - Query a count of all of events
    Given Create Multiple Events
    When Query All Events Count
    Then Should Return Status Code "200"
    And Should Be Equal As Integers  ${content}[Count]  6
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET006 - Query a count of all of events with specified device by device name
    Given Create Multiple Events
    When Query Events Count By Device Name  Device-Test-002
    Then Should Return Status Code "200"
    And Should Be Equal As Integers  ${content}[Count]  3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

*** Keywords ***
Should Return All Events
  ${count}=  Get Length  ${content}[events]
  Should Be Equal As Integers  ${count}  6

Events Should Be Linked To Specified Device
  ${count}=  Get Length  ${content}[events]
  Should Be Equal As Integers  ${count}  3
  FOR  ${index}  IN RANGE  0  3
    Should Be Equal  ${content}[events][${index}][deviceName]  Device-Test-001
  END

Events Should Be Created Between ${start} And ${end}
  ${count}=  Get Length  ${content}[events]
  Should Be Equal As Integers  ${count}  6
  FOR  ${index}  IN RANGE  0  6
    Should Be True  ${end} >= ${content}[events][${index}][origin] >=${start}
  END
