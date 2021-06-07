*** Settings ***
Library   RequestsLibrary
Library   OperatingSystem
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${supportNotificationsUrl}   ${URI_SCHEME}://${BASE_URL}:${SUPPORT_NOTIFICATIONS_PORT}
${notificationUri}           /api/${API_VERSION}/notification


*** Keywords ***
Generate Notifications
    [Arguments]  @{data_list}
    ${notification_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  notification=${data}
        Set to dictionary  ${json}   apiVersion=${API_VERSION}
        Append To List  ${notification_list}  ${json}
    END
    Set Test Variable  ${notification}  ${notification_list}

Generate A Notification Sample With serverity ${serverity}
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/support-notifications/notification_data.json  encoding=UTF-8
    ${notification}=  Evaluate  json.loads('''${data}''')  json
    Set To Dictionary  ${notification}  severity=${serverity}
    Generate Notifications  ${notification}

Generate ${number} Notifications Sample
    ${notification_list}  Create List
    FOR  ${INDEX}  IN RANGE  0  ${number}
        ${index}=  Get current milliseconds epoch time
        ${severity}  Evaluate  random.choice(["MINOR", "NORMAL", "CRITICAL"])
        ${data}=  Get File  ${WORK_DIR}/TAF/testData/support-notifications/notification_data.json  encoding=UTF-8
        ${notification}=  Evaluate  json.loads('''${data}''')  json
        Set To Dictionary  ${notification}  severity=${severity}
        Set To Dictionary  ${notification}  description=Test notification data ${index}
        Append To List  ${notification_list}  ${notification}
    END
    Generate Notifications  @{notification_list}

Create Notification ${entity}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Support Notifications  ${notificationUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}
    ...       ELSE  Retrieve Notification IDs

Retrieve Notification IDs
    ${notification_ids}=  Create list
    FOR  ${index}  IN RANGE  0  len(${content})
        Append To List  ${notification_ids}  ${content}[${index}][id]
    END
    Set Test Variable  ${notification_ids}  ${notification_ids}

Delete Notification By ID ${notificationId}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Notifications  ${notificationUri}/id/${notificationId}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Delete Multiple Notifications By IDs
    [Arguments]  @{notification_list}
    FOR  ${id}  IN  @{notification_list}
        Delete Notification By ID ${id}
    END

Delete Notifications By Age
    [Arguments]  ${age}=0
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Notifications  ${notificationUri}/age/${age}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=202  fail  ${response}!=202: ${content}

Query Notifications By Start/End Time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/start/${start_time}/end/${end_time}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Query Notifications Between Time ${start} And ${end} With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/start/${start}/end/${end}
    ...       params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Query Notification By ID ${notificationId}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/id/${notificationId}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Query All Notifications By Specified Category
    [Arguments]  ${category}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/category/${category}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query All Notifications By Specified Category ${category} With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/category/${category}
    ...       params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query All Notifications By Specified Label
    [Arguments]  ${label}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/label/${label}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query All Notifications By Specified Label ${label} With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/label/${label}  params=${parameter}=${value}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query All Notifications By Specified Subscription Name
    [Arguments]  ${subscription_name}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/subscription/name/${subscription_name}
    ...       headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query All Notifications By Specified Subscription Name ${subscription_name} With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/subscription/name/${subscription_name}
    ...       params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query All Notifications By Status
    [Arguments]  ${status}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/status/${status}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query All Notifications By Status ${status} With ${parameter}=${value}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Support Notifications  ${notificationUri}/status/${status}  params=${parameter}=${value}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail
