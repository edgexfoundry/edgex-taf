*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Job Delete Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-delete.log

*** Test Cases ***
CronSchedJobDELETE001 - Delete job
    # Jobs contain combination with definition type CRON/INTERVAL and actions type REST/EDGEXMESSAGEBUS/DEVICECONTROL
    Given Create Multiple Jobs
    When Delete Job By Name
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Job Has Been Deleted
    [Teardown]  Delete Jobs

ErrCronSchedJobDELETE001 - Delete job with invalid name
    When Delete Job By Invalid Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
