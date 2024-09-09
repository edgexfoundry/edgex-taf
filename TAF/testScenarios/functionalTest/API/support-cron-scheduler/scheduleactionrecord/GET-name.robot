*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Action Record Get By Nqme Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-action-record-get-name.log

*** Test Cases ***
CronSchedActionNameGET001 - Query schedule action record by name
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Job Name
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match totalCount
    And Job Name Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionNameGET002 - Query schedule action record by name with start
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Job Name With Start
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Greater Start Should Be Found
    And Job Name Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionNameGET003 - Query schedule action record by name with end
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Job Name With End
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Less Than End Should Be Found
    And Job Name Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionNameGET004 - Query schedule action record by name with start/end
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Job Name With Start/End
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Between Start/End Should Be Found
    And Job Name Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionNameGET005 - Query schedule action record by name with offset
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Job Name With Offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match totalCount-offset
    And Job Name Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionNameGET006 - Query schedule action record by name with limit
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Job Name With Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match Limit
    And Job Name Should Be The Same With Queried
    [Teardown]  Delete Jobs
