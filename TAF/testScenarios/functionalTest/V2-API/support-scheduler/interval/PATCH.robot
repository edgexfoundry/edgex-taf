*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Scheduler Interval PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-interval-patch.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalPATCH001 - Update interval
    Given Create Interval
    When Update Interval
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Intervals Should Be Updated
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalPATCH001 - Update interval with empty name
    When Update Interval With Empty Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrIntervalPATCH002 - Update interval with invalid name
    When Update Interval With Invalid Name Format
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrIntervalPATCH003 - Update interval with empty frequency
    Given Create Interval
    When Update Interval With Empty Frequency Format
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalPATCH004 - Update interval with invalid start
    Given Create Interval
    When Update Interval With Invalid Start Format
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalPATCH005 - Update interval with invalid end
    Given Create Interval
    When Update Interval With Invalid End Format
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}




