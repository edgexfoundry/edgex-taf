*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-cron-scheduler/supportCronSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Cron Scheduler Job POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-post.log

*** Test Cases ***
CronSchedJobPOST001 - Create multiple jobs
    # Jobs contain combination with definition type CRON/INTERVAL and actions type REST/EDGEXMESSAGEBUS/DEVICECONTROL
    Given Generate Jobs Sample
    When Create Jobs  ${jobs}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Jobs  @{job_names}

ErrCronSchedJobPOST001 - Create job with empty name
    Given Generate Jobs Sample
    And Set To Dictionary  ${jobs}[0][scheduleJob]  name=${EMPTY}
    When Create Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST002 - Create job with empty definition type
    Given Generate Jobs Sample
    And Set To Dictionary  ${jobs}[1][scheduleJob][definition]  type=${EMPTY}
    When Create Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST003 - Create job with empty definition scheduledef
    Given Generate Jobs Sample
    And Set To Dictionary  ${jobs}[1][scheduleJob][definition]  interval=${EMPTY}
    When Create Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST004 - Create job with invalid definition type
    Given Generate Jobs Sample
    And Set To Dictionary  ${jobs}[1][scheduleJob][definition]  type=INVALID
    When Create Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST005 - Create job with empty actions type
    Given Generate Jobs Sample
    And Set To Dictionary  ${jobs}[2][scheduleJob][actions][0]  type=${EMPTY}
    When Create Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST006 - Create job with invalid actions type
    Given Generate Jobs Sample
    And Set To Dictionary  ${jobs}[2][scheduleJob][actions][0]  type=INVALID
    When Create Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST007 - Create job with invalid admin state
    Given Generate Jobs Sample
    And Set To Dictionary  ${jobs}[3][scheduleJob]  adminState=INVALID
    When Create Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCronSchedJobPOST008 - Create job with startTimestamp > endTimestamp
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${endTime}  Evaluate  ${currentTime}-60000
    Given Generate Jobs Sample
    And Set To Dictionary  ${jobs}[4][scheduleJob][definition]  endTimestamp=${endTime}
    When Create Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
