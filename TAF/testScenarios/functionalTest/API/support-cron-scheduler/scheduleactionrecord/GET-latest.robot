*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Action Record Get Latest Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-action-record-get-latest.log

*** Test Cases ***
CronSchedActionLatestGET001 - Query latest schedule action record of job
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Latest Schedule Action Record By Job Name
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Should Be 1 And Only The Latest ActionRecord Of Job Should Be Found
    And Job Name Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionLatestGET002 - Query latest schedule action record with non-existent job
    When Query Latest Schedule Action Record With Non-existent Job
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
