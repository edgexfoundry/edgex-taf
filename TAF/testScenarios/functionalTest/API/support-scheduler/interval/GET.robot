*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Interval GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-interval-get.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalGET001 - Query all Intervals that are less than 20
    Given Generate 3 Intervals Sample
    And Create Interval  ${intervals}
    When Query All Intervals
    Then Should Return Status Code "200" And intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[intervals]) == 4  # Contains pre-created interval
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET002 - Query all Intervals that are more than 20
    Given Generate 21 Intervals Sample
    And Create Interval  ${intervals}
    When Query All Intervals
    Then Should Return Status Code "200" And intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[intervals]) == 20
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET003 - Query all Intervals by offset
    Given Generate 3 Intervals Sample
    And Create Interval  ${intervals}
    When Query All Intervals With offset=1
    Then Should Return Status Code "200" And intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[intervals]) == 3  # Contains pre-created interval
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET004 - Query all Intervals by limit
    Given Generate 3 Intervals Sample
    And Create Interval  ${intervals}
    When Query All Intervals With limit=2
    Then Should Return Status Code "200" And intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[intervals]) == 2
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET005 - Query all Intervals by limit = -1
    Given Generate 21 Intervals Sample
    And Create Interval  ${intervals}
    When Query All Intervals With limit=-1
    Then Should Return Status Code "200" And intervals
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[intervals]) == 22  # Contains pre-created interval
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

IntervalGET006 - Query Interval by name
    Given General An Interval Sample
    And Set To Dictionary  ${intervals}[0][interval]  name=interval-test
    And Create Interval  ${intervals}
    When Query Interval By Name interval-test
    Then Should Return Status Code "200" And interval
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Strings  interval-test  ${content}[interval][name]
    [Teardown]  Delete interval by name interval-test

ErrIntervalGET001 - Query Interval by not existed name
    When Query Interval By Name not-existed
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
