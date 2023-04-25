*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Interval POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-interval-post.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalPOST001 - Create interval
    Given Generate 3 Intervals Sample
    When Create Interval  ${intervals}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{interval_names}

ErrIntervalPOST001 - Create interval with empty name
    Given Generate 3 Intervals Sample
    And Set To Dictionary  ${intervals}[1][interval]  name=${EMPTY}
    When Create Interval  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrIntervalPOST002 - Create interval with invalid name
    Given Generate 3 Intervals Sample
    And Set To Dictionary  ${intervals}[1][interval]  name=invalid name
    When Create Interval  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrIntervalPOST003 - Create interval with empty interval value
    Given Generate 3 Intervals Sample
    And Set To Dictionary  ${intervals}[1][interval]  interval=${EMPTY}
    When Create Interval  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrIntervalPOST004 - Create interval with invalid start
    Given Generate 3 Intervals Sample
    And Set To Dictionary  ${intervals}[1][interval]  start=12345
    When Create Interval  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrIntervalPOST005 - Create interval with invalid end
    Given Generate 3 Intervals Sample
    And Set To Dictionary  ${intervals}[1][interval]  end=12345
    When Create Interval  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

