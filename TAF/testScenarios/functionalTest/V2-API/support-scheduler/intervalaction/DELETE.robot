*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Scheduler Intervalaction DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-delete.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
# /subscription/name/{name}
IntervalactionDELETE001 - Delete intervalaction by name
    Given Create Interval And Intervalaction
    When Delete Intervalaction By Name
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Intervalaction Should Not Be Found
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalactionDELETE001 - Delete Intervalaction with non-existed name
    When Delete Intervalaction By Non-existed Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

