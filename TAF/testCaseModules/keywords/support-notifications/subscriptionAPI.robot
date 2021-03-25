*** Settings ***
Library   RequestsLibrary
Library   OperatingSystem
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${supportNotificationsUrl}   ${URI_SCHEME}://${BASE_URL}:${SUPPORT_NOTIFICATION_PORT}
${api_version}       v2  # default value is v1, set "${api_version}  v2" in testsuite Variables section for v2 api
${subscriptionUri}         /api/${api_version}/subscription
${LOG_FILE_PATH}     ${WORK_DIR}/TAF/testArtifacts/logs/supportNotificaionsSubscriptionAPI.log

*** Keywords ***
Generate Subscriptions
    [Arguments]  @{data_list}
    ${subscription_list}=  Create List
    ${name_list}  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  subscription=${data}
        Set to dictionary  ${json}       apiVersion=${api_version}
        Append To List  ${subscription_list}  ${json}
        Append To List  ${name_list}  ${data}[name]
    END
    Set Test Variable  ${subscription}  ${subscription_list}
    Set Test Variable  ${subscription_names}  ${name_list}

Generate A Subscription Sample With ${type} Channel
    ${index}=  Get current milliseconds epoch time
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/support-notifications/subscription_data.json  encoding=UTF-8
    ${subscription}=  Evaluate  json.loads('''${data}''')  json
    ${channel}=  Load data file "support-notifications/channels_data.json" and get variable "${type}"
    Set To Dictionary  ${subscription}  name=Subscription-${index}
    Set To Dictionary  ${subscription}  channels=${channel}
    Generate Subscriptions  ${subscription}

Generate ${number} Subscriptions Sample
    ${subscription_list}  Create List
    FOR  ${INDEX}  IN RANGE  0  ${number}
        ${index}=  Get current milliseconds epoch time
        ${type}  Evaluate  random.choice(["EMAIL", "REST"])
        ${data}=  Get File  ${WORK_DIR}/TAF/testData/support-notifications/subscription_data.json  encoding=UTF-8
        ${subscription}=  Evaluate  json.loads('''${data}''')  json
        ${channel}=  Load data file "support-notifications/channels_data.json" and get variable "${type}"
        Set To Dictionary  ${subscription}  name=Subscription-${index}
        Set To Dictionary  ${subscription}  channels=${channel}
        Append To List  ${subscription_list}  ${subscription}
    END
    Generate Subscriptions  @{subscription_list}

Create Subscription ${entity}
    Create Session  Support Notifications  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Support Notifications  ${subscriptionUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Run Keyword If  "${api_version}" == "v1"  Run Keywords
    ...             Run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ...             AND  Set Test Variable  ${response}  ${resp.status_code}
    ...    ELSE IF  "${api_version}" == "v2"  Run Keywords  Set Response to Test Variables  ${resp}
    ...             AND  Run keyword if  ${response} != 207  log to console  ${content}

Delete Subscription By Name ${subscriptionName}
    Create Session  Support Notification  url=${supportNotificationsUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Support Notification  ${subscriptionUri}/name/${subscriptionName}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=204  log to console  ${resp.content}

Delete Multiple Subscriptions By Names
    [Arguments]  @{subscription_list}
    FOR  ${subscription}  IN  @{subscription_list}
        Delete Subscription By Name ${subscription}
    END

