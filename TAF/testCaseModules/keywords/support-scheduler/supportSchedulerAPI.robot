*** Settings ***
Library     RequestsLibrary
Library     String
Resource    TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${supportSchedulerUrl}  ${URI_SCHEME}://${BASE_URL}:${SUPPORT_SCHEDULER_PORT}
${jobUri}    /api/${API_VERSION}/job
${scheduleActionRecordUri}    /api/${API_VERSION}/scheduleactionrecord
${LOG_FILE_PATH}     ${WORK_DIR}/TAF/testArtifacts/logs/supportSchedulerAPI.log

*** Keywords ***
##  Job
Generate Job Definition
    [Arguments]  ${type}  ${value}
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${startTime}  Evaluate  ${currentTime}+1000  # Start after 1 second
    ${endTime}  Evaluate  ${startTime}+60000  # Set time interval to 1 minute

    IF  "${type}" == "INTERVAL"
        ${definition}  Create Dictionary  type=${type}  interval=${value}  startTimestamp=${startTime}  endTimestamp=${endTime}
    ELSE IF  "${type}" == "CRON"
        ${definition}  Create Dictionary  type=${type}  crontab=${value}  startTimestamp=${startTime}  endTimestamp=${endTime}
    ELSE
        Fail  ${type} is invalid. Definition Type only accepts the following values: INTERVAL and CRON.
    END
    RETURN  ${definition}

Generate Job Action
    [Arguments]  ${type}  ${payload}  ${field1}  ${field2}=${EMPTY}
    ${contentType}  Set Variable  application/json
    IF  "${type}" == "REST"
        ${action}  Create Dictionary  type=${type}  contentType=${contentType}  address=${field1}  method=${field2}
                   ...                injectEdgeXAuth=${true}  payload=${payload}
    ELSE IF  "${type}" == "EDGEXMESSAGEBUS"
        ${action}  Create Dictionary  type=${type}  contentType=${contentType}  topic=${field1}  payload=${payload}
    ELSE IF  "${type}" == "DEVICECONTROL"
        ${action}  Create Dictionary  type=${type}  contentType=${contentType}  deviceName=${field1}
                   ...                sourceName=${field2}   payload=${payload}
    ELSE
        Fail  ${type} is invalid. Action type only accepts the following values: REST, EDGEXMESSAGEBUS, and DEVICECONTROL.
    END
    RETURN  ${action}

General A Job Sample
    [Arguments]  ${definition}  ${definition_interval}  ${action}  ${action_field1}  ${action_field2}=${EMPTY}
    ...          ${action_payload}=${EMPTY}
    ${job_data}  Get File  ${WORK_DIR}/TAF/testData/support-scheduler/job.json  encoding=UTF-8
    ${job}  Evaluate  json.loads('''${job_data}''')  json
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${name}  Set Variable  job_${currentTime}
    Set To Dictionary  ${job}  name=${name}
    ${labels}  Create List  ${definition}  ${action}
    Set To Dictionary  ${job}  labels=${labels}
    ${definition}  Generate Job Definition  ${definition}  ${definition_interval}
    Set To Dictionary  ${job}  definition=${definition}
    ${action}  Generate Job Action  ${action}  ${action_payload}  ${action_field1}  ${action_field2}
    ${action_list}  Create List  ${action}
    Set To Dictionary  ${job}  actions=${action_list}
    RETURN  ${job}

Generate Jobs Sample
    ${crontab}  Set Variable  */30 * * * * *
    ${rest_address}  Set Variable  http://edgex-core-data:59880/api/v3/ping
    ${payload}  Create Dictionary  value=${999}
    ${payload_json}  Evaluate  json.dumps(${payload})
    ${job1}  General A Job Sample  INTERVAL  20s  REST  ${rest_address}  GET
    ${job2}  General A Job Sample  INTERVAL  20s  EDGEXMESSAGEBUS  edgex/job_test  ${EMPTY}  ${payload_json}
    ${job3}  General A Job Sample  INTERVAL  20s  DEVICECONTROL  deviceControl  Virtual_DeviceValue_INT8_RW
             ...                   ${payload_json}
    ${job4}  General A Job Sample  CRON  ${crontab}  REST  ${rest_address}  GET
    ${job5}  General A Job Sample  CRON  ${crontab}  EDGEXMESSAGEBUS  edgex/job_test  ${EMPTY}  ${payload_json}
    ${job6}  General A Job Sample  CRON  ${crontab}  DEVICECONTROL  deviceControl  Virtual_DeviceValue_INT16_RW
             ...                   ${payload_json}
    Generate Multiple Job  ${job1}  ${job2}  ${job3}  ${job4}  ${job5}  ${job6}

Generate A Job Data
    ${rest_address}  Set Variable  http://edgex-core-data:59880/api/v3/ping
    ${job}  General A Job Sample  INTERVAL  20s  REST  ${rest_address}  GET
    Generate Multiple Job  ${job}

Generate Multiple Job
    [Arguments]  @{data_list}
    ${job_list}  Create List
    ${job_name_list}  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}  Create Dictionary  scheduleJob=${data}
        Set to dictionary  ${json}  apiVersion=${API_VERSION}
        Append To List  ${job_list}  ${json}
        Append To List  ${job_name_list}  ${data}[name]
    END
    Set Test Variable  ${jobs}  ${job_list}
    Set Test Variable  ${job_names}  ${job_name_list}

Create Jobs
    [Arguments]  ${entity}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  POST On Session  Support Scheduler  ${jobUri}  json=${entity}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 207  log to console  ${content}

Update Jobs
    [Arguments]  ${entity}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  PATCH On Session  Support Scheduler  ${jobUri}  json=${entity}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 207  log to console  ${content}

Delete Job By Name
    [Arguments]  ${name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  DELETE On Session  Support Scheduler  ${jobUri}/name/${name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Delete Multiple Jobs
    [Arguments]  @{name_list}
    FOR  ${name}  IN  @{name_list}
        Delete Job By Name  ${name}
    END

Query Job By Name
    [Arguments]  ${name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${jobUri}/name/${name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Query All Jobs
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${jobUri}/all  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Trigger Job By Name
    [Arguments]  ${name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  POST On Session  Support Scheduler  ${jobUri}/trigger/name/${name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 202  log to console  ${content}

Create A Job
    ${job}  General A Job Sample  INTERVAL  30s  REST  http://edgex-core-metadata:59881/api/v3/ping  GET
    ${currentTime}  Get Current Milliseconds Epoch Time
    ${startTime}  Evaluate  ${currentTime}-1000
    ${endTime}  Evaluate  ${currentTime}+6000
    Set Test Variable  ${job_name}  trigger-manual
    Generate Multiple Job  ${job}
    Set To Dictionary  ${jobs}[0][scheduleJob]  name=${job_name}
    Set To Dictionary  ${jobs}[0][scheduleJob][definition]  startTimestamp=${startTime}
    Set To Dictionary  ${jobs}[0][scheduleJob][definition]  endTimestamp=${endTime}
    Create Jobs  ${jobs}

## Query Schedule Action Record
Query Schedule Action Record By Job Name
    [Arguments]  ${name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${scheduleActionRecordUri}/job/name/${name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Query All Schedule Action Record
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${scheduleActionRecordUri}/all  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Query All Schedule Action Record With ${params}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${scheduleActionRecordUri}/all  params=${params}
    ...      headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Query Latest Schedule Action Record By Job Name
    [Arguments]  ${name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${scheduleActionRecordUri}/latest/job/name/${name}
    ...      headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Query Schedule Action Record By Status
    [Arguments]  ${status}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${scheduleActionRecordUri}/status/${status}
    ...      headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Query Schedule Action Record By Job Name And Status
    [Arguments]  ${name}  ${status}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Support Scheduler  ${scheduleActionRecordUri}/job/name/${name}/status/${status}
    ...      headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response} != 200  log to console  ${content}

Create Jobs For Query Schedule Action Record
    Generate Jobs Sample
    Set To Dictionary  ${jobs}[0][scheduleJob][definition]  interval=2s
    Set To Dictionary  ${jobs}[1][scheduleJob][definition]  interval=1s
    Set To Dictionary  ${jobs}[3][scheduleJob][definition]  crontab=*/2 * * * * *
    Create Jobs  ${jobs}

ScheduleActionRecord Should Match With Parameters
    [Arguments]  ${params}
    Should be true  ${content}[totalCount] > 0
    FOR  ${key}  ${value}  IN  &{params}
        IF  "${key}" == "start"
            FOR  ${INDEX}  IN RANGE  len(${content}[scheduleActionRecords])
                Should Be True  ${content}[scheduleActionRecords][${INDEX}][created] >= ${value}
            END
        ELSE IF  "${key}" == "end"
            FOR  ${INDEX}  IN RANGE  len(${content}[scheduleActionRecords])
                Should Be True  ${content}[scheduleActionRecords][${INDEX}][created] <= ${value}
            END
        ELSE IF  "${key}" == "offset"
            IF  ${content}[totalCount] < 20
                Should Be True  len(${content}[scheduleActionRecords]) == ${content}[totalCount]-${offset}
            ELSE
                Should Be True  len(${content}[scheduleActionRecords]) == 20
            END
        ELSE IF  "${key}" == "limit"
            Should Be True  len(${content}[scheduleActionRecords]) <= ${limit}
        ELSE
            Fail  Paramter only accepts the following values: start, end, offset, limit
        END
    END

Job Name ${name} Should Be Correct
    FOR  ${INDEX}  IN RANGE  len(${content}[scheduleActionRecords])
        Should Be Equal As Strings  ${name}  ${content}[scheduleActionRecords][${INDEX}][jobName]
    END


