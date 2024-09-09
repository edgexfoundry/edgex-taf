*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Job PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-patch.log

*** Test Cases ***
CronSchedJobPATCH001 - Update jobs
    # Update different field on each job
    Given Create Multiple Jobs
    When Update Jobs
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Jobs Should Be Updated
    [Teardown]  Delete Jobs

ErrCronSchedJobPATCH001 - Update job with empty definition type
    Given Create Multiple Jobs
    When Update Jobs With Empty Definition Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrCronSchedJobPATCH002 - Update job with empty definition scheduledef
    Given Create Multiple Jobs
    When Update Jobs With Empty Definition ScheduleDef
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrCronSchedJobPATCH003 - Update job with invalid definition type
    Given Create Multiple Jobs
    When Update Jobs With Invalid Definition Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrCronSchedJobPATCH004 - Update job with empty actions type
    Given Create Multiple Jobs
    When Update Jobs With Empty Actions Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrCronSchedJobPATCH005 - Update job with invalid actions type
    Given Create Multiple Jobs
    When Update Jobs With Invalid Actions Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrCronSchedJobPATCH006 - Update job with invalid admin state
    Given Create Multiple Jobs
    When Update Jobs With Invalid AdminState
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrCronSchedJobPATCH007 - Update job with startTimestamp > endTimestamp
    Given Create Multiple Jobs
    When Update Jobs With Incorrect Definition Timestamp
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs
