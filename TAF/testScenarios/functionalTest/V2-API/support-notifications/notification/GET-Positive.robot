*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/cleanupAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags   v2-api

*** Variables ***
${SUITE}          Support Notifications Notification GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-get-positive.log
${category}       health-check
${label}          simple

*** Test Cases ***
# /notification/category/{category}
NotificationGET001 - Query notifications with specified category
    Given Create Multiple Notifications With Different Categories
    When Query All Notifications By Specified Category  ${category}
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 4
    And totalCount Should be 4
    And Notifications Should Be Linked To Specified Category: ${category}
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

NotificationGET002 - Query notifications with specified category by offset
    Given Create Multiple Notifications With Different Categories
    When Query All Notifications By Specified Category ${category} With offset=1
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 3
    And totalCount Should be 4
    And Notifications Should Be Linked To Specified Category: ${category}
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

NotificationGET003 - Query notifications with specified category by limit
    Given Create Multiple Notifications With Different Categories
    When Query All Notifications By Specified Category ${category} With limit=3
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 3
    And totalCount Should be 4
    And Notifications Should Be Linked To Specified Category: ${category}
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

# /notification/label/{label}
NotificationGET004 - Query notifications with specified label
    Given Create Multiple Notifications With Different Labels
    When Query All Notifications By Specified Label  ${label}
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 4
    And totalCount Should be 4
    And Notifications Should Be Linked To Specified Label: ${label}
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

NotificationGET005 - Query notifications with specified label by offset
    Given Create Multiple Notifications With Different Labels
    When Query All Notifications By Specified Label ${label} With offset=2
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 2
    And totalCount Should be 4
    And Notifications Should Be Linked To Specified Label: ${label}
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

NotificationGET006 - Query notifications with specified label by limit
    Given Create Multiple Notifications With Different Labels
    When Query All Notifications By Specified Label ${label} With limit=2
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 2
    And totalCount Should be 4
    And Notifications Should Be Linked To Specified Label: ${label}
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

# /notification/status/{status}
NotificationGET007 - Query notifications with specified status
    Given Create Subscriptions And Notifications For Different Status
    When Query All Notifications By Status  ESCALATED
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 1
    And totalCount Should be 1
    And Only Notifications With Status ESCALATED Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  ${subscription_names}[0]  ESCALATION

NotificationGET008 - Query notifications with specified status by offset
    Given Create Subscriptions And Notifications For Different Status
    When Query All Notifications By Status PROCESSED With offset=1
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 2
    And Only Notifications With Status PROCESSED Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  ${subscription_names}[0]  ESCALATION

NotificationGET009 - Query notifications with specified status by limit
    Given Create Subscriptions And Notifications For Different Status
    When Query All Notifications By Status PROCESSED With limit=1
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 1
    And Only Notifications With Status PROCESSED Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  ${subscription_names}[0]  ESCALATION

*** Keywords ***
Create Multiple Notifications With Different Categories
    Generate 5 Notifications Sample
    Set To Dictionary  ${notification}[0][notification]  category=testing
    Create Notification ${notification}  # 4 notifications are in health-check category

Create Multiple Notifications With Different Labels
    ${new_labels}=  Create List  new_label
    Generate 5 Notifications Sample
    Set To Dictionary  ${notification}[0][notification]  labels=@{new_labels}
    Append To List  ${notification}[1][notification][labels]  new_label
    Create Notification ${notification}  # 4 notifications are with simple label

Create Subscriptions And Notifications For Different Status
    Create ESCALATION Subscription Sample With REST Channel
    Generate A Subscription Sample With EMAIL Channel
    Set To Dictionary  ${subscription}[0][subscription]  resendInterval=1s
    Create Subscription ${subscription}
    Generate 3 Notifications Sample
    Set To Dictionary  ${notification}[0][notification]  severity=CRITICAL  # resend fails and generate ESCALATED notification
    Set To Dictionary  ${notification}[1][notification]  severity=NORMAL
    Set To Dictionary  ${notification}[2][notification]  severity=MINOR
    Create Notification ${notification}
    sleep  8s  # for resending

Notifications Should Be Linked To Specified Category: ${specified_category}
    ${notifications}=  Set Variable  ${content}[notifications]
    FOR  ${item}  IN  @{notifications}
        Should Be Equal  ${item}[category]  ${specified_category}
    END

Notifications Should Be Linked To Specified Label: ${specified_label}
    ${notifications}=  Set Variable  ${content}[notifications]
    FOR  ${item}  IN  @{notifications}
        List Should Contain Value  ${item}[labels]  ${specified_label}
    END

Only Notifications With Status ${status} Should Be Listed
    ${notifications}=  Set Variable  ${content}[notifications]
    FOR  ${item}  IN  @{notifications}
        Should Be Equal  ${item}[status]  ${status}
    END
