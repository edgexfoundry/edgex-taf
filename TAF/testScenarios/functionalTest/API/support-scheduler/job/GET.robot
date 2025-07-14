*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Job Get Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-get-positive.log

*** Test Cases ***
SchedulerJobGET001 - Query all jobs
    Given Generate Jobs Sample
    And Create Jobs  ${jobs}
    When Query All Jobs
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ${content}[scheduleJobs] Count Should Match totalCount
    [Teardown]  Delete Multiple Jobs  @{job_names}

SchedulerJobGET002 - Query all jobs by labels
    Given Set Test Variable  ${label}  INTERVAL
    And Generate Jobs Sample
    And Create Jobs  ${jobs}
    When Query All Jobs With labels=${label}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And Only scheduleJobs With Labels ${label} Should Be Found
    [Teardown]  Delete Multiple Jobs  @{job_names}

SchedulerJobGET003 - Query all jobs by offset
    Given Set Test Variable  ${offset}  ${2}
    And Generate Jobs Sample
    And Create Jobs  ${jobs}
    When Query All Jobs With offset=${offset}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ${content}[scheduleJobs] Count Should Match totalCount-offset
    [Teardown]  Delete Multiple Jobs  @{job_names}

SchedulerJobGET004 - Query all jobs by limit
    Given Set Test Variable  ${limit}  ${3}
    And Generate Jobs Sample
    And Create Jobs  ${jobs}
    When Query All Jobs With limit=${limit}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Is Greater Than Zero And ${content}[scheduleJobs] Count Should Match Limit
    [Teardown]  Delete Multiple Jobs  @{job_names}

SchedulerJobGET005 - Query job by name
    Given Set Test Variable  ${job_name}  get-test
    And Generate A Job Data
    And Set To Dictionary  ${jobs}[0][scheduleJob]  name=${job_name}
    And Create Jobs  ${jobs}
    When Query Job By Name  ${job_name}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Job By Name  ${job_name}

ErrSchedulerJobGET001 - Query job by name with non-existent job
    When Query Job By Name  non-existed
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms


*** Keywords ***
Query All Jobs With ${params}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${jobUri}/all  params=${params}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}

totalCount Is Greater Than Zero And Only scheduleJobs With Labels ${label} Should Be Found
    Should contain  ${content}  totalCount
    Should be true  '${content}[totalCount]' > '0'
    FOR  ${INDEX}  IN RANGE  ${content}[totalCount]
        Should Contain  ${content}[scheduleJobs][${INDEX}][labels]  ${label}
    END
        
