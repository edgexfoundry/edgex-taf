*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Scheduler Interval DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-interval-delete.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalDELETE001 - Delete interval by name
    Given Create Interval
    When Delete Interval By Name
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Interval Should Not Be Found

ErrIntervalDELETE001 - Delete interval with non-existed name
    When Delete Interval By Non-existed Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrIntervalDELETE002 - Delete interval that is using by intervalaction
    Given Create Interval
    And Create Intervalaction
    When Delete Interval
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
