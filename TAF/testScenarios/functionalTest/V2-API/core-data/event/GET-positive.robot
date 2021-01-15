*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Event GET Postive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-positive.log
${api_version}    v2

*** Test Cases ***
EventGET001 - Query all events
    [Tags]  Skipped
    Given Create Multiple Events
    When Query All Events
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

EventGET002 - Query event by ID
    [Tags]  SmokeTest
    Given Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Simple Reading
    And Create Event With Device-Test-001 And Profile-Test-001
    When Query Event By Event Id "${id}"
    Then Should Return Status Code "200" And event
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    #[Teardown]  Delete Events

EventGET003 - Query all events with specified device by device name
    [Tags]  Skipped
    Given Create Multiple Events With Several Devices
    When Query All Events With Specified Device
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Events Should Be Linked To Specified Device
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

EventGET004 - Query events by start/end time
    [Tags]  Skipped
    Given Create Multiple Events
    When Query Events By Start/End Time
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Events Should Be Created Within Given Time
    [Teardown]  Delete Events

EventGET005 - Query a count of all of events
    Given Create Multiple Events
    When Query All Events Count
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    #And Should Be Equal  ${content}[Count]  6
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    #[Teardown]  Delete Events

EventGET006 - Query a count of all of events with specified device by device name
    [Tags]  Skipped
    Given Create Multiple Events
    When Query All Events Count With Specified Device
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Count Should Be Correct
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

*** Keywords ***
Create Multiple Events
  FOR  ${index}  IN RANGE  0  3   # total: 6 events
    Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Simple Reading
    Create Event With Device-Test-001 and Profile-Test-001
    Generate Event Sample  Event  Device-Test-002  Profile-Test-001  Simple Reading  Simple Float Reading
    Create Event With Device-Test-002 and Profile-Test-001
  END
