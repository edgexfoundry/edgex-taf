*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Scheduler Interval GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-interval-get.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalGET001 - Query all Intervals that are less than 20
    Given Create Multiple Intervals That Less Than 20
    When Query All Intervals
    Then Should Return Status Code "200" And Intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Created Intervals Should Be Found
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET002 - Query all Intervals that are more than 20
    Given Create Multiple Intervals That More Than 20
    When Query All Intervals
    Then Should Return Status Code "200" And Intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Found 20 Intervals
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET003 - Query all Intervals by offset
    Given Create 3 Intervals
    When Query All Intervals With offset=1
    Then Should Return Status Code "200" And Intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[Intervals]) == 2
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET004 - Query all Intervals by limit
    Given Create 3 Intervals
    When Query All Intervals With limit=2
    Then Should Return Status Code "200" And Intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[Intervals]) == 2
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET005 - Query all Intervals by limit = -1
    Given Create Multiple Intervals That More Than 20
    When Query All Intervals With limit=-1
    Then Should Return Status Code "200" And Intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Created Intervals Should Be Found
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET005 - Query Interval by name
    Given Create Multiple Intervals
    When Query Interval By Name
    Then Should Return Status Code "200" And Interval
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Queried Interval Found
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalGET001 - Query Interval by not existed name
    When Query Interval By Not Existed Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
