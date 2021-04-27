*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

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
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

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

ErrIntervalPATCH003 - Update interval with empty frequency
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  frequency=${EMPTY}
    When Update Intervals  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalPATCH004 - Update interval with invalid frequency
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  frequency=99
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

ErrIntervalPATCH007 - Update interval with invalid runOnce
    Given General An Interval Sample
    And Create Interval  ${intervals}
    And Set To Dictionary  ${intervals}[0][interval]  runOnce=invalid
    When Update Intervals  ${intervals}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

*** Keywords ***
Create Intervals And Generate Multiple Intervals Sample For Updating Data
    Generate 3 Intervals Sample
    Create Interval  ${intervals}
    Query Interval By Name ${intervals}[2][interval][name]
    ${runOnce}  Run Keyword If  "runOnce" in "${intervals}[2][interval]"  Convert To Boolean  false
                 ...       ELSE  Convert To Boolean  true
    ${end}  Get current ISO 8601 time
    Set Test Variable  ${frequency_value}  8h
    Set Test Variable  ${end_value}  ${end}
    Set Test Variable  ${runOnce_value}  ${runOnce}
    ${update_frequency}  Create Dictionary  name=${intervals}[0][interval][name]  frequency=${frequency_value}
    ${update_start}  Create Dictionary  name=${intervals}[1][interval][name]  end=${end_value}
    ${update_runOnce}  Create Dictionary  name=${intervals}[2][interval][name]  runOnce=${runOnce_value}
    Generate Intervals  ${update_frequency}  ${update_start}  ${update_runOnce}

Intervals Should Be Updated
    FOR  ${name}  IN  @{interval_names}
        Query Interval By Name ${name}
        Run Keyword If  "${name}" == "${intervals}[0][interval][name]"
        ...             Should Be Equal  ${content}[interval][frequency]  ${frequency_value}
        ...    ELSE IF  "${name}" == "${intervals}[1][interval][name]"
        ...             Should Be Equal  ${content}[interval][end]  ${end_value}
        ...    ELSE IF  "${name}" == "${intervals}[2][interval][name]" and ${runOnce_value} == True
        ...             Should Be Equal  ${content}[interval][runOnce]  ${runOnce_value}
        ...       ELSE  Should Not Contain  ${content}[interval]  runOnce
    END
