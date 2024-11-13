*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Job PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-patch.log

*** Test Cases ***
SchedulerJobPATCH001 - Update jobs
    # Update different field on each job
    Given Create Jobs And Generate Update Body
    When Update Jobs  ${jobs}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Jobs Should Be Updated
    [Teardown]  Delete Jobs

ErrSchedulerJobPATCH001 - Update job with empty definition type
    Given Create Jobs And Generate Update Body
    And Set To Dictionary  ${jobs}[0][scheduleJob][definition]  type=${EMPTY}
    When Update Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrSchedulerJobPATCH002 - Update job with empty definition scheduledef
    Given Create Jobs And Generate Update Body
    And Set To Dictionary  ${jobs}[0][scheduleJob][definition]  crontab=${EMPTY}
    When Update Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrSchedulerJobPATCH003 - Update job with invalid definition type
    Given Create Jobs And Generate Update Body
    And Set To Dictionary  ${jobs}[0][scheduleJob][definition]  type=INVALID
    When Update Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrSchedulerJobPATCH004 - Update job with empty actions type
    Given Create Jobs And Generate Update Body
    And Set To Dictionary  ${jobs}[3][scheduleJob][actions][0]  type=${EMPTY}
    Log  ${jobs}
    When Update Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrSchedulerJobPATCH005 - Update job with invalid actions type
    Given Create Jobs And Generate Update Body
    And Set To Dictionary  ${jobs}[1][scheduleJob][actions][0]  type=INVALID
    Log  ${jobs}
    When Update Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrSchedulerJobPATCH006 - Update job with invalid admin state
    Given Create Jobs And Generate Update Body
    And Set To Dictionary  ${jobs}[2][scheduleJob]  adminState=INVALID
    When Update Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

ErrSchedulerJobPATCH007 - Update job with startTimestamp > endTimestamp
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${endTime}  Evaluate  ${currentTime}-60000
    Given Create Jobs And Generate Update Body
    And Set To Dictionary  ${jobs}[0][scheduleJob][definition]  startTimestamp=${currentTime}
    And Set To Dictionary  ${jobs}[0][scheduleJob][definition]  endTimestamp=${endTime}
    When Update Jobs  ${jobs}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Jobs

*** Keywords ***
Generate Update Body
    ${definition}  Generate Job Definition  CRON  CRON_TZ=UTC 0 0 2 2 *
    ${rest_address}  Set Variable  http://edgex-core-metadata:59881/api/v3/ping
    ${payload}  Create Dictionary  value=${1234}
    ${payload_json}  Evaluate  json.dumps(${payload})
    Remove From Dictionary  ${definition}  startTimestamp
    Remove From Dictionary  ${definition}  endTimestamp
    ${action_1}  Generate Job Action  DEVICECONTROL  ${payload_json}  deviceControl  Virtual_DeviceValue_INT16_RW
    ${action_2}  Generate Job Action  REST  ${EMPTY}  ${rest_address}  GET
    ${action_3}  Generate Job Action  EDGEXMESSAGEBUS  ${payload_json}  edgex/job_test
    ${list_1}  Create List  ${action_1}
    ${list_2}  Create List  ${action_2}
    ${list_3}  Create List  ${action_3}
    ${update_definition}  Create Dictionary  name=${job_names}[0]  definition=${definition}
    ${update_action_1}  Create Dictionary  name=${job_names}[3]  actions=${list_1}
    ${update_action_2}  Create Dictionary  name=${job_names}[4]  actions=${list_2}
    ${update_action_3}  Create Dictionary  name=${job_names}[5]  actions=${list_3}

    Set Test Variable  ${update_def}  ${update_definition}
    Set Test Variable  ${update_act_1}  ${update_action_1}
    Set Test Variable  ${update_act_2}  ${update_action_2}
    Set Test Variable  ${update_act_3}  ${update_action_3}
    Generate Multiple Job  ${update_definition}  ${update_action_1}  ${update_action_2}  ${update_action_3}

Jobs Should Be Updated
    FOR  ${name}  IN  @{job_names}
        Query Job By Name  ${name}
        IF  "${name}" == "${job_names}[0]"
            Should Be Equal  ${content}[scheduleJob][definition][type]  ${update_def}[definition][type]
            Should Be Equal  ${content}[scheduleJob][definition][crontab]  ${update_def}[definition][crontab]
        ELSE IF  "${name}" == "${job_names}[1]"
            ${payload_decode}  Evaluate  base64.b64decode('${content}[scheduleJob][actions][0][payload]').decode('utf-8')  modules=base64
            Should Be Equal  ${content}[scheduleJob][actions][0][type]  ${update_act_1}[actions][0][type]
            Should Be Equal  ${content}[scheduleJob][actions][0][deviceName]  ${update_act_1}[actions][0][deviceName]
            Should Be Equal  ${content}[scheduleJob][actions][0][sourceName]  ${update_act_1}[actions][0][sourceName]
            Should Be Equal  ${payload_decode}  ${update_act_1}[actions][0][payload]
        ELSE IF  "${name}" == "${job_names}[2]"
            Should Be Equal  ${content}[scheduleJob][actions][0][type]  ${update_act_2}[actions][0][type]
            Should Be Equal  ${content}[scheduleJob][actions][0][address]  ${update_act_2}[actions][0][address]
            Should Be Equal  ${content}[scheduleJob][actions][0][method]  ${update_act_2}[actions][0][method]
        ELSE IF  "${name}" == "${job_names}[3]"
            ${payload_decode}  Evaluate  base64.b64decode('${content}[scheduleJob][actions][0][payload]').decode('utf-8')  modules=base64
            Should Be Equal  ${content}[scheduleJob][actions][0][type]  ${update_act_3}[actions][0][type]
            Should Be Equal  ${content}[scheduleJob][actions][0][topic]  ${update_act_3}[actions][0][topic]
            Should Be Equal  ${payload_decode}  ${update_act_1}[actions][0][payload]
        END
    END

Create Jobs And Generate Update Body
    Generate Jobs Sample
    Create Jobs  ${jobs}
    Generate Update Body

Delete Jobs
    Query All Jobs
    @{names}  Create List
    FOR  ${INDEX}  IN RANGE  ${content}[totalCount]
        Append To List  ${names}  ${content}[scheduleJobs][${INDEX}][name]
    END
    Delete Multiple Jobs  @{names}
