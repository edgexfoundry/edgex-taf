*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-cron-scheduler/supportCronSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Cron Scheduler Action Record Get All Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-action-record-get-all.log

*** Test Cases ***
CronSchedActionGET001 - Query all schedule action record
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    When Query All Schedule Action Record
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ${content}[scheduleActionRecords] Count Should Match totalCount
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionGET002 - Query all schedule action record with start
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${time}  Evaluate  ${currentTime}+1400
    ${params}  Create Dictionary  start=${time}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  5s  # Wait For Running Schedule Job
    When Query All Schedule Action Record By Parameters  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionGET003 - Query all schedule action record with end
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${time}  Evaluate  ${currentTime}+3000
    ${params}  Create Dictionary  end=${time}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  5s  # Wait For Running Schedule Job
    When Query All Schedule Action Record By Parameters  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionGET004 - Query all schedule action record with start/end
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${startTime}  Evaluate  ${currentTime}+1400
    ${endTime}  Evaluate  ${currentTime}+6400
    ${params}  Create Dictionary  start=${startTime}  end=${endTime}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  5s  # Wait For Running Schedule Job
    When Query All Schedule Action Record By Parameters  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionGET005 - Query all schedule action record with offset
    Set Test Variable  ${offset}  ${2}
    ${params}  Create Dictionary  offset=${offset}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  5s  # Wait For Running Schedule Job
    When Query All Schedule Action Record By Parameters  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionGET006 - Query all schedule action record by start and limit
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${time}  Evaluate  ${currentTime}+1400
    Set Test Variable  ${limit}  ${2}
    ${params}  Create Dictionary  start=${time}  limit=${limit}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  5s  # Wait For Running Schedule Job
    When Query All Schedule Action Record By Parameters  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    [Teardown]  Delete Multiple Jobs  @{job_names}

*** Keywords ***
Query All Schedule Action Record By Parameters
    [Arguments]  ${params_dict}
    Create Session  Support Cron Scheduler  url=${supportCronSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Cron Scheduler  ${scheduleActionRecordUri}/all  params=${params_dict}
    ...      headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}
