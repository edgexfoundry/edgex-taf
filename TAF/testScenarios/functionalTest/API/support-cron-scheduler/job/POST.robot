*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Support Cron Scheduler Job POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-post.log

*** Test Cases ***
CronSchedJobPOST001 - Create multiple jobs
    # Jobs contain combination with definition type CRON/INTERVAL and actions type REST/EDGEXMESSAGEBUS/DEVICECONTROL
    When Create Multiple Jobs
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrCronSchedJobPOST001 - Create job with empty name
    When Create Jobs With Empty Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST002 - Create job with empty definition type
    When Create Jobs With Empty Definition Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST003 - Create job with empty definition scheduledef
    When Create Jobs With Empty Definition ScheduleDef
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST004 - Create job with invalid definition type
    When Create Jobs With Invalid Definition Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST005 - Create job with empty actions type
    When Create Jobs With Empty Actions Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST006 - Create job with invalid actions type
    When Create Jobs With Invalid Actions Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST007 - Create job with invalid admin state
    When Create Jobs With Invalid AdminState
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST008 - Create job with startTimestamp > endTimestamp
    When Create Jobs With Incorrect Definition Timestamp
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
