*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Action Record Get All Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-action-record-get-all.log

*** Test Cases ***
CronSchedActionGET001 - Query all schedule action record
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query All Schedule Action Record
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match totalCount
    And Job Name Should Be Matched With Created Jobs
    [Teardown]  Delete Jobs

CronSchedActionGET002 - Query all schedule action record with start
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query All Schedule Action Record With Start
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Greater Start Should Be Found
    And Job Name Should Be Matched With Created Jobs
    [Teardown]  Delete Jobs

CronSchedActionGET003 - Query all schedule action record with end
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query All Schedule Action Record With End
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Less Than End Should Be Found
    And Job Name Should Be Matched With Created Jobs
    [Teardown]  Delete Jobs

CronSchedActionGET004 - Query all schedule action record with start/end
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query All Schedule Action Record With Start/End
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Between Start/End Should Be Found
    And Job Name Should Be Matched With Created Jobs
    [Teardown]  Delete Jobs

CronSchedActionGET005 - Query all schedule action record with offset
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query All Schedule Action Record With offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match totalCount-offset
    And Job Name Should Be Matched With Created Jobs
    [Teardown]  Delete Jobs

CronSchedActionGET006 - Query all schedule action record by start with limit
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query All Schedule Action Record With Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match Limit
    And Job Name Should Be Matched With Created Jobs
    [Teardown]  Delete Jobs
