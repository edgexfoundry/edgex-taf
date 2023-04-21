*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Intervalaction DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-delete.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
# /subscription/name/{name}
IntervalactionDELETE001 - Delete intervalaction by name
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    When Delete intervalAction by name ${intervalAction_name}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Intervalaction Should Not Be Found
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionDELETE001 - Delete Intervalaction with non-existed name
    When Delete Intervalaction By Name Non-existed
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Intervalaction Should Not Be Found
  Query IntervalAction By Name ${intervalAction_name}
  Should return status code "404"
