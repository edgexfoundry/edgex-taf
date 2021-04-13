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
General A Interval Sample
    ${index}=  Get current milliseconds epoch time
    ${start}  Get current ISO 8601 time
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/support-scheduler/interval.json  encoding=UTF-8
    ${interval}=  Evaluate  json.loads('''${data}''')  json
    Set To Dictionary  ${interval}  name=interval_${index}
    Set To Dictionary  ${interval}  start=${start}
    Generate Intervals  ${interval}
    Set Test Variable  ${interval_name}  ${interval}[name]

Generate Intervals
    [Arguments]  @{data_list}
    ${interval_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  interval=${data}  apiVersion=${API_VERSION}
        Append To List  ${interval_list}  ${json}
    END
    Set Test Variable  ${intervals}  ${interval_list}

Create interval
    [Arguments]  ${entity}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Support Scheduler  ${intervalUri}  json=${entity}  headers=${headers}
    ...                expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Delete interval by name ${interval_name}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Scheduler  ${intervalUri}/name/${interval_name}  headers=${headers}
    ...                expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}


##  Interval Action
General A IntervalAction Sample
    ${index}=  Get current milliseconds epoch time
    ${intervalAction}=  Load data file "support-scheduler/interval_action.json" and get variable "RESTAddress"
    Set To Dictionary  ${intervalAction}  name=intervalAction_${index}
    Generate IntervalActions  ${intervalAction}
    Set Test Variable  ${intervalAction_name}  ${intervalAction}[name]

Generate IntervalActions
    [Arguments]  @{data_list}
    ${intervalAction_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  action=${data}  apiVersion=${API_VERSION}
        Append To List  ${intervalAction_list}  ${json}
    END
    Set Test Variable  ${intervalActions}  ${intervalAction_list}

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

