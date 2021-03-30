*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Reading GET Postive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-reading-positive.log
${api_version}    v2

*** Test Cases ***
ReadingGET001 - Query all readings
    Given Create Multiple Events
    When Query All Readings
    Then Should Return Status Code "200"
    And Should Be True  len(${content}[readings]) == 9
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET002 - Query all readings with offset
    Given Create Multiple Events
    When Query All Readings With offset=3
    Then Should Return Status Code "200"
    And Should Be True  len(${content}[readings]) == 6
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET003 - Query all readings with limit
    Given Create Multiple Events
    When Query All Readings With limit=3
    Then Should Return Status Code "200"
    And Should Be True  len(${content}[readings]) == 3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET004 - Query reading by resoucreName
    Given Create Multiple Events
    When Query Readings By resourceName  Simple-Reading
    Then Should Return Status Code "200"
    And Should Be True  len(${content}[readings]) == 6
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET005 - Query all readings with specified device by device name
    Given Create Multiple Events
    When Query Readings By Device Name  Device-Test-001
    Then Should Return Status Code "200"
    And Should Be True  len(${content}[readings]) == 3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET006 - Query readings by start/end time
    Given Create Multiple Events Twice To Get Start/End Time
    When Query Readings By Start/End Time  ${start_time}  ${end_time}
    Then Should Return Status Code "200"
    And Readings Should Be Created Between ${start_time} And ${end_time}
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET007 - Query a count of all of readings
    Given Create Multiple Events
    When Query All Readings Count
    Then Should Return Status Code "200"
    And Should Be Equal As Integers  ${content}[Count]  9
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET008 - Query a count of all of readings with specified device by device name
    Given Create Multiple Events
    When Query Readings Count By Device Name  Device-Test-002
    Then Should Return Status Code "200"
    And Should Be Equal As Integers  ${content}[Count]  6
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

*** Keywords ***
Readings Should Be Created Between ${start} And ${end}
  ${count}=  Get Length  ${content}[readings]
  Should Be Equal As Integers  ${count}  9
  FOR  ${index}  IN RANGE  0  9
    Should Be True  ${end} >= ${content}[readings][${index}][origin] >=${start}
  END
