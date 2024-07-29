*** Settings ***
Library  RequestsLibrary
Resource  TAF/testCaseModules/keywords/core-keeper/coreKeeperAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${coreKeeperUrl}  ${URI_SCHEME}://${BASE_URL}:${CORE_KEEPER_PORT}
${coreKeeperRegUri}    /api/${API_VERSION}/registry
${coreKeeperKVsUri}    /api/${API_VERSION}/kvs/key

*** Keywords ***
Generate Registry Data
    [Arguments]  ${serviceId}  ${host}  ${port}
    ${data}  Get File  ${WORK_DIR}/TAF/testData/core-keeper/registry_data.json  encoding=UTF-8
    ${registry_data}  Evaluate  json.loads('''${data}''')  json
    ${json}  Create Dictionary  registration=${registry_data}
    Set to dictionary  ${json}  apiVersion=${API_VERSION}
    Set To Dictionary  ${json}[registration]  serviceId=${serviceId}
    Set To Dictionary  ${json}[registration]  host=${host}
    Set To Dictionary  ${json}[registration]  port=${port}
    Set Test Variable  ${Registry}  ${json}

Register A New Service
    [Arguments]  ${entity}
    Create Session  Core Keeper  url=${coreKeeperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  POST On Session  Core Keeper  ${coreKeeperRegUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Deregister Service
    [Arguments]  ${serviceId}
    Create Session  Core Keeper  url=${coreKeeperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}  DELETE On Session  Core Keeper  ${coreKeeperRegUri}/serviceId/${serviceId}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=204  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Query All Registered Services
    Create Session  Core Keeper  url=${coreKeeperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Core Keeper  ${coreKeeperRegUri}/all  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Query Registered Service By ServiceId
    [Arguments]  ${serviceId}
    Create Session  Core Keeper  url=${coreKeeperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  GET On Session  Core Keeper  ${coreKeeperRegUri}/serviceId/${serviceId}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Update Registered Service
    [Arguments]  ${entity}
    Create Session  Core Keeper  url=${coreKeeperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}  PUT On Session  Core Keeper  ${coreKeeperRegUri}  json=${entity}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}


