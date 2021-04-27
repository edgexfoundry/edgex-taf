*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Scheduler Interval DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-interval-delete.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalDELETE001 - Delete interval by name
    Given General An Interval Sample
    And Set To Dictionary  ${intervals}[0][interval]  name=interval-test
    And Create Interval  ${intervals}
    When Delete Interval By Name interval-test
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Interval interval-test Should Not Be Found

ErrIntervalDELETE001 - Delete interval with non-existed name
    When Delete Interval By Name Not-existed
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrIntervalDELETE002 - Delete interval that is using by intervalaction
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    When Delete Interval By Name ${interval_name}
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Interval ${interval_name} Should Be Found
    [Teardown]  Run Keywords  Delete intervalAction by name ${intervalAction_name}
                ...      AND  Delete Interval By Name ${interval_name}

*** Keywords ***
Interval ${name} Should Not Be Found
    Query Interval By Name ${name}
    Should Return Status Code "404"

Interval ${name} Should Be Found
    Query Interval By Name ${name}
    Should Return Status Code "200"

