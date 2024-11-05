*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-cron-scheduler/supportCronSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Cron Scheduler Action Record Get By Nqme Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-cron-scheduler-action-record-get-name.log

*** Test Cases ***
CronSchedActionNameGET001 - Query schedule action record by name
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${job_name}  ${job_names}[0]
    When Query Schedule Action Record By Job Name  ${job_name}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ${content}[scheduleActionRecords] Count Should Match totalCount
    And Job Name ${job_name} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionNameGET002 - Query schedule action record by name with start
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${time}  Evaluate  ${currentTime}+1400
    ${params}  Create Dictionary  start=${time}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${job_name}  ${job_names}[1]
    When Query Schedule Action Record By Job Name With Parameters  ${job_name}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Job Name ${job_name} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionNameGET003 - Query schedule action record by name with end
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${time}  Evaluate  ${currentTime}+3000
    ${params}  Create Dictionary  end=${time}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${job_name}  ${job_names}[1]
    When Query Schedule Action Record By Job Name With Parameters  ${job_name}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Job Name ${job_name} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionNameGET004 - Query schedule action record by name with start/end
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${startTime}  Evaluate  ${currentTime}+1400
    ${endTime}  Evaluate  ${currentTime}+6400
    ${params}  Create Dictionary  start=${startTime}  end=${endTime}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${job_name}  ${job_names}[1]
    When Query Schedule Action Record By Job Name With Parameters  ${job_name}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Job Name ${job_name} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionNameGET005 - Query schedule action record by name with offset
    Set Test Variable  ${offset}  ${1}
    ${params}  Create Dictionary  offset=${offset}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${job_name}  ${job_names}[1]
    When Query Schedule Action Record By Job Name With Parameters  ${job_name}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Job Name ${job_name} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

CronSchedActionNameGET006 - Query schedule action record by name with limit
    Set Test Variable  ${limit}  ${1}
    ${params}  Create Dictionary  limit=${limit}
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${job_name}  ${job_names}[1]
    When Query Schedule Action Record By Job Name With Parameters  ${job_name}  ${params}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And ScheduleActionRecord Should Match With Parameters  ${params}
    And Job Name ${job_name} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

*** Keywords ***
Query Schedule Action Record By Job Name With Parameters
    [Arguments]  ${name}  ${params_dict}
    Create Session  Support Cron Scheduler  url=${supportCronSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Cron Scheduler  ${scheduleActionRecordUri}/job/name/${name}  params=${params_dict}
    ...      headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}
