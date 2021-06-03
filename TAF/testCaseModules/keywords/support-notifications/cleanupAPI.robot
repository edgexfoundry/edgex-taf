*** Settings ***
Library   RequestsLibrary
Library   OperatingSystem
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${supportNotificationsUrl}   ${URI_SCHEME}://${BASE_URL}:${SUPPORT_NOTIFICATIONS_PORT}
${cleanupUri}                /api/${API_VERSION}/cleanup

*** Keywords ***
Cleanup All Notifications And Transmissions
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Notifications  ${cleanupUri}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=202  fail  ${response}!=202: ${content}

Cleanup All Notifications And Transmissions By Age
    [Arguments]  ${age}=0
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Notifications  ${cleanupUri}/age/${age}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=202  fail  ${response}!=202: ${content}