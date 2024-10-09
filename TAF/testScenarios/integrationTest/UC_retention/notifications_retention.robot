*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/cleanupAPI.robot
Suite Setup  Run keywords  Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
             ...      AND  Cleanup All Notifications And Transmissions
             ...      AND  Enable Notifications Retention
             ...      AND  Update Configuration On Registry Service  ${CONSOL_PATH}/Writable/LogLevel  DEBUG
Suite Teardown  Run Keywords  Disable Notifications Retention
                ...      AND  Update Configuration On Registry Service  ${CONSOL_PATH}/Writable/LogLevel  INFO
                ...      AND  Run Teardown Keywords
Force Tags      MessageBus=redis

*** Variables ***
${SUITE}          support-notifications Retention
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications_retention.log
${CONSOL_PATH}  /support-notifications
${maxCap}  5
${minCap}  2
${interval}  3s

*** Test Cases ***
NotificationsRetention001 - notifications retention is executed if reading count is over MaxCap value
    When Create Subscriptions 1 And Notifications 10
    ${timestamp}  Get current epoch time
    And Set Test Variable  ${timestamp}  ${timestamp}
    And Sleep  ${interval}
    And Wait Until Keyword Succeeds  3x  2s  Found Purge Log in support-notifications
    Then Stored Notifications Count Should Be Less Than: 10
    And Stored Transmissions Are Belong To Stored Notifications
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Multiple Subscriptions By Names  @{subscription_names}

NotificationsRetention002 - notifications retention is not executed if reading count is less than MaxCap value
    When Create Subscriptions 1 And Notifications 3
    And Sleep  ${interval}
    Then Stored Notifications Count Should Be Equal: 3
    And Stored Transmissions Are Belong To Stored Notifications
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Multiple Subscriptions By Names  @{subscription_names}

*** Keywords ***
Enable Notifications Retention
    ${keys}  Create List  Enabled  Interval  MaxCap  MinCap
    ${values}  Create List  true  3s  ${maxCap}  ${minCap}
    FOR  ${key}  ${value}  IN ZIP  ${keys}  ${values}
        ${path}=  Set Variable  ${CONSOL_PATH}/Retention/${key}
        Update Configuration On Registry Service  ${path}  ${value}
    END
    Restart Services  support-notifications

Stored Notifications Count Should Be ${condition}: ${number}
    # Set end date to current date + 1 day
    ${date}  get current date
    ${date}  Add Time To Date  ${date}  1 day
    ${epoch_time}=  convert date    ${date}  epoch
    ${timestamp}=    evaluate   int(${epoch_time}*1000)
    Query Notifications By Start/End Time  0  ${timestamp}
    Run Keyword If  "${condition}" == "Equal"  Should Be True  ${content}[totalCount] == ${number}
    ...    ELSE IF  "${condition}" == "Less Than"  Should Be True  ${content}[totalCount] < ${number}
    ...       ELSE  Fail  Invalid condition value: ${condition}

Get Notification Ids
    ${ids}  Create List
    FOR  ${INDEX}  IN RANGE  len(${content}[notifications])
        Append To List  ${ids}  ${content}[notifications][${INDEX}][id]
    END
    RETURN  ${ids}

Stored Transmissions Are Belong To Stored Notifications
    ${stored_notifiction_ids}  Get Notification Ids
    Query All Transmissions
    ${transmission_notifictionIds}  Create List
    FOR  ${INDEX}  IN RANGE  len(${content}[transmissions])
        Append To List  ${transmission_notifictionIds}  ${content}[transmissions][${INDEX}][notificationId]
    END
    Remove Duplicates  ${transmission_notifictionIds}
    Lists Should Be Equal  ${stored_notifiction_ids}  ${transmission_notifictionIds}  ignore_order=True

Disable Notifications Retention
    ${path}=  Set Variable  ${CONSOL_PATH}/Retention/Enabled
    Update Configuration On Registry Service  ${path}  false
    Restart Services  support-notifications

Create Subscriptions ${subscriptions_num} And Notifications ${notifications_num}
    Generate ${subscriptions_num} Subscriptions Sample
    Create Subscription ${subscription}
    Generate ${notifications_num} Notifications Sample
    Create Notification ${notification}

Found Purge Log in ${service}
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service} ${timestamp}
             ...     shell=True  stderr=STDOUT  output_encoding=UTF-8  timeout=10s
    Log  ${logs.stdout}
    Should Contain  ${logs.stdout}  Purging the notification
