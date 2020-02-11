*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  TAF.utils.src.setup.setup_teardown
Library  String
Resource  ./commonKeywords.robot

*** Variables ***
${loggingUrl}  http://${BASE_URL}:${SUPPORT_LOGGING_PORT}

*** Keywords ***
Remove device service logs
    Create Session  Logging Service  url=${loggingUrl}
    ${resp}=  Delete Request  Logging Service  /api/v1/logs/originServices/${SERVICE_NAME}/0/0
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
