*** Settings ***
Library     RequestsLibrary
Library     String

*** Variables ***
${supportSchedulerUrl}  ${URI_SCHEME}://${BASE_URL}:${SUPPORT_SCHEDULER_PORT}
${intervalUri}    /api/v1/interval
${intervalActionUri}    /api/v1/intervalaction
${LOG_FILE_PATH}     ${WORK_DIR}/TAF/testArtifacts/logs/supportSchedulerAPI.log

*** Keywords ***
##  Interval
Create interval
    [Arguments]  ${request_body}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${json}=    evaluate    json.loads('''${request_body}''')    json
    ${interval_resp}=  Post Request  Support Scheduler  ${intervalUri}  json=${json}  headers=${headers}
    Set test variable  ${response}  ${interval_resp.status_code}
    [Return]  ${interval_resp}

Delete interval by name "${interval_name}"
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${interval_resp}=  Delete Request  Support Scheduler  ${intervalUri}/name/${interval_name}  headers=${headers}
    Set test variable  ${response}  ${interval_resp.status_code}


##  Interval Action
Create intervalAction
    [Arguments]  ${request_body}
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${json}=    evaluate    json.loads('''${request_body}''')    json
    ${intervalAction_resp}=  Post Request  Support Scheduler  ${intervalActionUri}  json=${json}  headers=${headers}
    Set test variable  ${response}  ${intervalAction_resp.status_code}
    [Return]  ${intervalAction_resp}

Delete intervalAction by name "${intervalAction_name}"
    Create Session  Support Scheduler  url=${supportSchedulerUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${interval_resp}=  Delete Request  Support Scheduler  ${intervalActionUri}/name/${intervalAction_name}  headers=${headers}
    Set test variable  ${response}  ${interval_resp.status_code}

