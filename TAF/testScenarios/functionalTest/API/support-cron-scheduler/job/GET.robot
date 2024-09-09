*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Job Get Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-get-positive.log

*** Test Cases ***
CronSchedJobGET001 - Query all jobs
    Given Create Multiple Jobs
    When Query All Jobs
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And scheduleJobs Count Should Match totalCount
    [Teardown]  Delete Jobs

CronSchedJobGET002 - Query all jobs by labels
    Given Create Multiple Jobs With Labels
    When Query All Jobs By Labels
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And scheduleJobs Count Should Be Correct
    [Teardown]  Delete Jobs

CronSchedJobGET003 - Query all jobs by offset
    Given Create Multiple Jobs
    When Query All Jobs By Offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And scheduleJobs Count Should Match totalCount-offset
    [Teardown]  Delete Jobs

CronSchedJobGET004 - Query all jobs by limit
    Given Create Multiple Jobs
    When Query All Jobs By Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And scheduleJobs Count Should Match Limit
    [Teardown]  Delete Jobs

CronSchedJobGET005 - Query job by name
    Given Create Multiple Jobs
    When Query Job By Name
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Job Should Be Found
    [Teardown]  Delete Jobs

ErrCronSchedJobGET001 - Query job by name with non-existent job
    When Query Job By Name With Non-existent Job
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
