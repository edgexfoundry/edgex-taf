*** Settings ***
Library  OperatingSystem
Library  RequestsLibrary

*** Variables ***
${coreCommandUrl}  http://${BASE_URL}:${CORE_COMMAND_PORT}
${deviceUri}   /api/v1/device

*** Keywords ***
Query command by device id
    [Tags]  GET
    ${deviceId}=   get environment variable  deviceId
    Create Session  Core Command  url=${coreCommandUrl}
    ${resp}=  Get Request  Core Command    ${deviceUri}/${deviceId}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ${device_json}=  evaluate  json.loads('''${resp.content}''')  json
    log  ${device_json}
    set environment variable  commandName  ${device_json}[commands][0][name]
