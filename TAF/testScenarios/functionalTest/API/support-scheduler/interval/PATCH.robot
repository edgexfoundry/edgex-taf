*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Interval PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-interval-patch.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalPATCH001 - Update interval
    Given Create Intervals And Generate Multiple Intervals Sample For Updating Data
    When Update Intervals  ${intervals}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Intervals Should Be Updated
    [Teardown]  Delete Multiple Intervals By Names  @{all_interval_names}

ErrIntervalPATCH001 - Update interval with empty name
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  name=${EMPTY}
    When Update Intervals  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalPATCH002 - Update interval with invalid name
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  name=invalid name
    When Update Intervals  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalPATCH003 - Update interval with empty interval value
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  interval=${EMPTY}
    When Update Intervals  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalPATCH004 - Update interval with invalid interval value
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  interval=99
    When Update Intervals  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalPATCH005 - Update interval with invalid start
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  start=12345678000
    When Update Intervals  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalPATCH006 - Update interval with invalid end
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  end=99h
    When Update Intervals  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

*** Keywords ***
Create Intervals And Generate Multiple Intervals Sample For Updating Data
    Generate 3 Intervals Sample
    Set Test Variable  ${all_interval_names}  ${interval_names}
    Create Interval  ${intervals}
    Query Interval By Name ${intervals}[2][interval][name]
    ${end}  Get current ISO 8601 time
    Set Test Variable  ${interval_value}  8h
    Set Test Variable  ${end_value}  ${end}
    ${update_interval}  Create Dictionary  name=${intervals}[0][interval][name]  interval=${interval_value}
    ${update_start}  Create Dictionary  name=${intervals}[1][interval][name]  end=${end_value}
    Generate Intervals  ${update_interval}  ${update_start}

Intervals Should Be Updated
    FOR  ${name}  IN  @{interval_names}
        Query Interval By Name ${name}
        Run Keyword If  "${name}" == "${intervals}[0][interval][name]"
        ...             Should Be Equal  ${content}[interval][interval]  ${interval_value}
        ...    ELSE IF  "${name}" == "${intervals}[1][interval][name]"
        ...             Should Be Equal  ${content}[interval][end]  ${end_value}
    END
