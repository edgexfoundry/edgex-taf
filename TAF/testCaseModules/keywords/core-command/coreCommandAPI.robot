*** Settings ***
Library  OperatingSystem
Library  RequestsLibrary

*** Variables ***
${coreCommandUrl}  ${URI_SCHEME}://${BASE_URL}:${CORE_COMMAND_PORT}
${deviceUri}   /api/v1/device

*** Keywords ***
Query command by device id
    [Tags]  GET
    Create Session  Core Command  url=${coreCommandUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Command    ${deviceUri}/${device_id}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ${device_json}=  evaluate  json.loads('''${resp.content}''')  json
    log  ${device_json}
    set test variable  ${command_name}  ${device_json}[commands][0][name]
