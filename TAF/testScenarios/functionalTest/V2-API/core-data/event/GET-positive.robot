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

*** Test Cases ***
EventGET001 - Query all events
    Given Create Multiple Events
    When Query All Events
    Then Should Return Status Code "200"
    And totalCount Should be 6
    And Should Return 6 Events
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET002 - Query all events by limit = -1 and MaxResultCount= 5
    Given Set MaxResultCount=5 For Core-Data On Consul
    And Create Multiple Events
    When Query All Events With limit=-1
    Then Should Return Status Code "200"
    And totalCount Should be 6
    And Should Return 5 Events
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete All Events By Age
    ...         AND  Set MaxResultCount=50000 For Core-Data On Consul

EventGET003 - Query event by ID
    [Tags]  SmokeTest
    Given Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  Simple Reading
    And Create Event With Device-Test-001 And Profile-Test-001 And Command-Test-001
    When Query Event By Event Id "${id}"
    Then Should Return Status Code "200" And event
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET004 - Query all events with specified device by device name
    Given Create Multiple Events
    When Query Events By Device Name  Device-Test-001
    Then Should Return Status Code "200"
    And totalCount Should be 3
    And Events Should Be Linked To Specified Device
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET005 - Query events by start/end time
    Given Create Multiple Events Twice To Get Start/End Time
    When Query Events By Start/End Time  ${start_time}  ${end_time}
    Then Should Return Status Code "200"
    And totalCount Should be 6
    And Events Should Be Created Between ${start_time} And ${end_time}
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET006 - Query a count of all of events
    Given Create Multiple Events
    When Query All Events Count
    Then Should Return Status Code "200"
    And Should Be Equal As Integers  ${content}[Count]  6
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventGET007 - Query a count of all of events with specified device by device name
    Given Create Multiple Events
    When Query Events Count By Device Name  Device-Test-002
    Then Should Return Status Code "200"
    And Should Be Equal As Integers  ${content}[Count]  3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

*** Keywords ***
Should Return ${number} Events
  ${count}=  Get Length  ${content}[events]
  Should Be Equal As Integers  ${count}  ${number}

Events Should Be Linked To Specified Device
  ${number}=  Set Variable  3
  Should Return ${number} Events
  FOR  ${index}  IN RANGE  0  ${number}
    Should Be Equal  ${content}[events][${index}][deviceName]  Device-Test-001
  END

Events Should Be Created Between ${start} And ${end}
  ${number}=  Set Variable  6
  Should Return ${number} Events
  FOR  ${index}  IN RANGE  0  ${number}
    Should Be True  ${end} >= ${content}[events][${index}][origin] >=${start}
  END

Set MaxResultCount=${number} For Core-Data On Consul
   ${path}=  Set Variable  /v1/kv/edgex/core/${CONSUL_CONFIG_VERSION}/core-data/Service/MaxResultCount
   Update Service Configuration On Consul  ${path}  ${number}
   Restart Services  data
