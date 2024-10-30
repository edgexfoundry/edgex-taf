*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-cron-scheduler/supportCronSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Cron Scheduler Job Delete Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-delete.log

*** Test Cases ***
CronSchedJobDELETE001 - Delete job
    # Jobs contain combination with definition type CRON/INTERVAL and actions type REST/EDGEXMESSAGEBUS/DEVICECONTROL
    Given Set Test Variable  ${job_name}  delete-test
    And Generate A Job Data
    And Set To Dictionary  ${jobs}[0][scheduleJob]  name=${job_name}
    And Create Jobs  ${jobs}
    When Delete Job By Name  ${job_name}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Job Has Been Deleted

ErrCronSchedJobDELETE001 - Delete job with invalid name
    When Delete Job By Name  not-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Job Has Been Deleted
    Query Job By Name  ${job_name}
    Should Return Status Code "404"
