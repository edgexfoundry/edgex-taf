*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  TAF/testCaseModules/keywords/setup/setup_teardown.py
Library  String

*** Variables ***
${loggingUrl}  ${URI_SCHEME}://${BASE_URL}:${SUPPORT_LOGGING_PORT}

*** Keywords ***
Remove device service logs
    Create Session  Logging Service  url=${loggingUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Logging Service  /api/v1/logs/originServices/${SERVICE_NAME}/0/0  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  fail  ${resp.status_code}!=200: ${resp.content}

