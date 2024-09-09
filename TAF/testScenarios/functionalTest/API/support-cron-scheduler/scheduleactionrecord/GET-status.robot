*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Action Record Get By Status Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-action-record-get-status.log

*** Test Cases ***
CronSchedActionStatusGET001 - Query schedule action record by status
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Status
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match totalCount
    And Status Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionStatusGET002 - Query schedule action record by status with start
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Status With Start
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Greater Start Should Be Found
    And Status Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionStatusGET003 - Query schedule action record by status with end
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Status With End
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Less Than End Should Be Found
    And Status Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionStatusGET004 - Query schedule action record by status with start/end
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Status With Start/End
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Between Start/End Should Be Found
    And Status Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionStatusGET005 - Query schedule action record by status with offset
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Status With offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match totalCount-offset
    And Status Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionStatusGET006 - Query schedule action record by status with limit
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Status With Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match Limit
    And Status Should Be The Same With Queried
    [Teardown]  Delete Jobs
