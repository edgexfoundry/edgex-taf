*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-cron-scheduler/supportCronSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Cron Scheduler Job POST Trigger Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-post-trigger.log

*** Test Cases ***
CronSchedJobTriggerPOST001 - Trigger job by manual
    Given Create A Job
    When Trigger Job By Name  ${job_name}
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Job Has Been Triggered
    [Teardown]  Delete Job By Name  ${job_name}

CronSchedJobTriggerPOST002 - Trigger job by manual with the startTimestamp is not arrived yet
    Given Create A Job Which startTimestamp Is Not Arrived Yet
    When Trigger Job By Name  ${job_name}
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Job By Name  ${job_name}

ErrCronSchedJobTriggerPOST001 - Trigger job by manual with non-existent job
    When Trigger Job By Name  not-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Job Has Been Triggered
    Query Schedule Action Record By Job Name  ${job_name}
    Should Be True  ${content}[totalCount] > 0

Create A Job Which startTimestamp Is Not Arrived Yet
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${startTime}  Evaluate  ${currentTime}+600000
    ${endTime}  Evaluate  ${currentTime}+660000
    ${job}  General A Job Sample  INTERVAL  30s  REST  http://edgex-core-metadata:59881/api/v3/ping  GET
    Set Test Variable  ${job_name}  trigger-fail
    Generate Multiple Job  ${job}
    Set To Dictionary  ${jobs}[0][scheduleJob]  name=${job_name}
    Set To Dictionary  ${jobs}[0][scheduleJob][definition]  startTimestamp=${startTime}
    Set To Dictionary  ${jobs}[0][scheduleJob][definition]  endTimestamp=${endTime}
    Create Jobs  ${jobs}
