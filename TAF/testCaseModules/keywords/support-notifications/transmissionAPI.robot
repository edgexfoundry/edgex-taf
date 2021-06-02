*** Settings ***
Library   RequestsLibrary
Library   OperatingSystem
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${supportNotificationsUrl}   ${URI_SCHEME}://${BASE_URL}:${SUPPORT_NOTIFICATIONS_PORT}
${transmissionUri}           /api/${API_VERSION}/transmission

*** Keywords ***
Query All Transmissions
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/all  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query Transmissions By Specified Subscription
    [Arguments]  ${subscription_name}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/subscription/name/${subscription_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query Transmissions By Start/End Time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/start/${start_time}/end/${end_time}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Delete Transmissions By Age
    [Arguments]  ${age}=0
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Notifications  ${transmissionUri}/age/${age}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=202  fail  ${response}!=202: ${content}

