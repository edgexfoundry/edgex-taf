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
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/all  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query All Transmissions With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/all  params=${parameter}=${value}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query Transmissions By Specified Subscription
    [Arguments]  ${subscription_name}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/subscription/name/${subscription_name}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query Transmissions By Specified Subscription ${subscription_name} With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/subscription/name/${subscription_name}
    ...         params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query Transmissions By Specified Status
    [Arguments]  ${status}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/status/${status}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Query Transmissions By Specified Status ${status} With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/status/${status}  params=${parameter}=${value}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query Transmissions By Start/End Time
    [Arguments]  ${start}   ${end}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/start/${start}/end/${end}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Query Transmissions Between Time ${start} And ${end} With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/start/${start}/end/${end}
    ...       params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query Transmissions By Id
    [Arguments]  ${id}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${transmissionUri}/id/${id}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Delete Transmissions By Age
    [Arguments]  ${age}=0
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Notifications  ${transmissionUri}/age/${age}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
