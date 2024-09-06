*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Job POST Trigger Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-post-trigger.log

*** Test Cases ***
CronSchedJobTriggerPOST001 - Trigger job by manual
    Given Create Multiple Jobs
    When Trigger Job By Manual
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Job Has Been Triggered
    [Teardown]  Delete Jobs

ErrCronSchedJobTriggerPOST001 - Trigger job by manual with non-existent job
    When Trigger Job By Manual With Non-existent Job
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobTriggerPOST002 - Trigger job by manual with the startTimestamp is not arrived yet
    Given Create Multiple Jobs
    When Trigger Job Which startTimestamp Is Not Arrived
    Then Should Return Status Code "500"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs
