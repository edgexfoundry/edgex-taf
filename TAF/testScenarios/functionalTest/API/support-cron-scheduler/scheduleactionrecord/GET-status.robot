*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-cron-scheduler/supportCronSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Cron Scheduler Action Record Get By Status Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-action-record-get-status.log

*** Test Cases ***
CronSchedActionStatusGET001 - Query schedule action record by status
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${status}  SUCCEEDED
    When Query Schedule Action Record By Status  ${status}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ${content}[scheduleActionRecords] Count Should Match totalCount
    And Status ${status} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionStatusGET002 - Query schedule action record by status with start
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${time}  Evaluate  ${currentTime}+1400
    ${params}  Create Dictionary  start=${time}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${status}  SUCCEEDED
    When Query Schedule Action Record By Status With Parameters  ${status}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Status ${status} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionStatusGET003 - Query schedule action record by status with end
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${time}  Evaluate  ${currentTime}+3000
    ${params}  Create Dictionary  end=${time}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${status}  SUCCEEDED
    When Query Schedule Action Record By Status With Parameters  ${status}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Status ${status} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionStatusGET004 - Query schedule action record by status with start/end
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${startTime}  Evaluate  ${currentTime}+1400
    ${endTime}  Evaluate  ${currentTime}+6400
    ${params}  Create Dictionary  start=${startTime}  end=${endTime}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${status}  SUCCEEDED
    When Query Schedule Action Record By Status With Parameters  ${status}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Status ${status} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionStatusGET005 - Query schedule action record by status with offset
    Set Test Variable  ${offset}  ${2}
    ${params}  Create Dictionary  offset=${offset}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${status}  SUCCEEDED
    When Query Schedule Action Record By Status With Parameters  ${status}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Status ${status} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionStatusGET006 - Query schedule action record by status with limit
    Set Test Variable  ${limit}  ${2}
    ${params}  Create Dictionary  limit=${limit}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${status}  SUCCEEDED
    When Query Schedule Action Record By Status With Parameters  ${status}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Status ${status} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

*** Keywords ***
Query Schedule Action Record By Status With Parameters
    [Arguments]  ${status}  ${params_dict}
    Create Session  Support Cron Scheduler  url=${supportCronSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Cron Scheduler  ${scheduleActionRecordUri}/status/${status}  params=${params_dict}
    ...      headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}

Status ${status} Should Be Correct
    FOR  ${INDEX}  IN RANGE  len(${content}[scheduleActionRecords])
        Should Be Equal As Strings  ${status}  ${content}[scheduleActionRecords][${INDEX}][status]
    END
