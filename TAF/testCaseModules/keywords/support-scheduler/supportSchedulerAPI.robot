*** Settings ***
Library     RequestsLibrary
Library     String
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${supportSchedulerUrl}  ${URI_SCHEME}://${BASE_URL}:${SUPPORT_SCHEDULER_PORT}
${intervalUri}    /api/${API_VERSION}/interval
${intervalActionUri}    /api/${API_VERSION}/intervalaction
${LOG_FILE_PATH}     ${WORK_DIR}/TAF/testArtifacts/logs/supportSchedulerAPI.log

*** Keywords ***
##  Interval
General An Interval Sample
    ${index}=  Get current milliseconds epoch time
    ${start}  Get current ISO 8601 time
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/support-scheduler/interval.json  encoding=UTF-8
    ${interval}=  Evaluate  json.loads('''${data}''')  json
    Set To Dictionary  ${interval}  name=interval_${index}
    Set To Dictionary  ${interval}  start=${start}
    Generate Intervals  ${interval}
    Set Test Variable  ${interval_name}  ${interval}[name]

Generate ${number} Intervals Sample
    ${interval_list}  Create List
    ${frequency_list}  Create List  24h  60m  60s  3600ms
    FOR  ${INDEX}  IN RANGE  0  ${number}
        ${index}=  Get current milliseconds epoch time
        ${start}  Get current ISO 8601 time
        ${frequency}  Evaluate  random.choice(@{frequency_list})  random
        ${runOnce_str}  Evaluate  random.choice(['true', 'false'])  modules=random
        ${runOnce}=  Convert To Boolean  ${runOnce_str}
        ${data}=  Get File  ${WORK_DIR}/TAF/testData/support-scheduler/interval.json  encoding=UTF-8
        ${interval}=  Evaluate  json.loads('''${data}''')  json
        Set To Dictionary  ${interval}  name=interval-${index}
        Set To Dictionary  ${interval}  start=${start}
        Set To Dictionary  ${interval}  frequency=${frequency}
        Set To Dictionary  ${interval}  runOnce=${runOnce}
        Append To List  ${interval_list}  ${interval}
    END
    Generate Intervals  @{interval_list}

Generate Intervals
    [Arguments]  @{data_list}
    ${interval_list}=  Create List
    ${name_list}  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  interval=${data}  apiVersion=${API_VERSION}
        Append To List  ${interval_list}  ${json}
        Append To List  ${name_list}  ${data}[name]
    END
    Set Test Variable  ${intervals}  ${interval_list}
    Set Test Variable  ${interval_names}  ${name_list}

Create interval
    [Arguments]  ${entity}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Support Scheduler  ${intervalUri}  json=${entity}  headers=${headers}
    ...                expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Update Intervals
    [Arguments]  ${entity}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  PATCH ON Session  Support Scheduler  ${intervalUri}  json=${entity}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Delete interval by name ${interval_name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Scheduler  ${intervalUri}/name/${interval_name}  headers=${headers}
    ...                expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}

Delete Multiple Intervals By Names
    [Arguments]  @{interval_list}
    FOR  ${interval}  IN  @{interval_list}
        Delete Interval By Name ${interval}
    END

Query Interval By Name ${name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Scheduler  ${intervalUri}/name/${name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Query All Intervals
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Scheduler  ${intervalUri}/all  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query All Intervals With ${parameter}=${value}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Scheduler  ${intervalUri}/all  params=${parameter}=${value}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

##  Interval Action
General An IntervalAction Sample
    [Arguments]  ${address}=RESTAddress
    ${index}=  Get current milliseconds epoch time
    ${intervalAction}=  Load data file "support-scheduler/interval_action.json" and get variable "${address}"
    Set To Dictionary  ${intervalAction}  name=intervalAction_${index}
    Generate IntervalActions  ${intervalAction}
    Set Test Variable  ${intervalAction_name}  ${intervalAction}[name]

Create An Interval And Generate An Intervalaction Sample
    [Arguments]  ${address}=RESTAddress
    General An Interval Sample
    Create Interval  ${intervals}
    General An IntervalAction Sample  ${address}
    Set To Dictionary  ${intervalActions}[0][action]  intervalName=${interval_name}

Generate ${number} Invervals And IntervalActions Sample
    Generate ${number} Intervals Sample
    Create Interval  ${intervals}
    ${intervalAction_list}  Create List
    FOR  ${INDEX}  IN RANGE  0  ${number}
        ${index}=  Get current milliseconds epoch time
        ${address}=  Evaluate  random.choice(['RESTAddress', 'MQTTAddress', 'EmailAddress'])
        ${interval}=  Evaluate  random.choice(@{interval_names})
        ${intervalAction}=  Load data file "support-scheduler/interval_action.json" and get variable "${address}"
        Set To Dictionary  ${intervalAction}  name=intervalAction_${index}
        Set To Dictionary  ${intervalAction}  intervalName=${interval}
        Append To List  ${intervalAction_list}  ${intervalAction}
    END
    Generate IntervalActions  @{intervalAction_list}

Generate IntervalActions
    [Arguments]  @{data_list}
    ${intervalAction_list}=  Create List
    ${name_list}  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  action=${data}  apiVersion=${API_VERSION}
        Append To List  ${intervalAction_list}  ${json}
        Append To List  ${name_list}  ${data}[name]
    END
    Set Test Variable  ${intervalActions}  ${intervalAction_list}
    Set Test Variable  ${intervalAction_names}  ${name_list}

Create intervalAction
    [Arguments]  ${entity}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Support Scheduler  ${intervalActionUri}  json=${entity}  headers=${headers}
    ...                      expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Delete intervalAction by name ${intervalAction_name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Scheduler  ${intervalActionUri}/name/${intervalAction_name}
    ...                headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}

Delete Multiple IntervalActions By Names
    [Arguments]  @{intervalAction_list}
    FOR  ${intervalAction}  IN  @{intervalAction_list}
         Delete intervalAction by name ${intervalAction}
    END

Query IntervalAction By Name ${name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Scheduler  ${intervalActionUri}/name/${name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Query All IntervalActions
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Scheduler  ${intervalActionUri}/all  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query All IntervalActions With ${parameter}=${value}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Scheduler  ${intervalActionUri}/all  params=${parameter}=${value}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Update IntervalActions
    [Arguments]  ${entity}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  PATCH ON Session  Support Scheduler  ${intervalActionUri}  json=${entity}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}
