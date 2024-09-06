*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Action Record Get By Name And Status Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-action-record-get-name-status.log

*** Test Cases ***
CronSchedActionAllGET001 - Query schedule action record by name and status
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Name And Status
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match totalCount
    And Job Name and Status Both Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionAllGET002 - Query schedule action record by name and status with start
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Name And Status With Start
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Greater Start Should Be Found
    And Job Name and Status Both Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionAllGET003 - Query schedule action record by name and status with end
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Name And Status With End
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Less Than End Should Be Found
    And Job Name and Status Both Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionAllGET004 - Query schedule action record by name and status with start/end
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Name And Status With Start/End
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only Created Of ActionRecord Between Start/End Should Be Found
    And Job Name and Status Both Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionAllGET005 - Query schedule action record by name and status with offset
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Name And Status With offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match totalCount-offset
    And Job Name and Status Both Should Be The Same With Queried
    [Teardown]  Delete Jobs

CronSchedActionAllGET006 - Query schedule action record by name and status with limit
    Given Create Multiple Jobs
    And Wait For Running Schedule Job
    When Query Schedule Action Record By Name And Status With Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ActionRecord Count Should Match Limit
    And Job Name and Status Both Should Be The Same With Queried
    [Teardown]  Delete Jobs
