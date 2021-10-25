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
${SUITE}          Support Notifications Notification GET Positive II Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-get-positive-II.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /notification/start/{start}/end/{end}
NotificationGET010 - Query notifications with time range
    Given Create Multiple Notifications With Different Categories And Labels
    When Query Notifications By Start/End Time  ${start}  ${end}
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notification Count Should Be 6 And Are Created Between ${start} And ${end}
    And totalCount Should be 6
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

NotificationGET011 - Query notifications with time range by offset
    Given Create Multiple Notifications With Different Categories And Labels
    When Query Notifications Between Time ${start} And ${end} With offset=1
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notification Count Should Be 5 And Are Created Between ${start} And ${end}
    And totalCount Should be 6
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

NotificationGET012 - Query notifications with time range by limit
    Given Create Multiple Notifications With Different Categories And Labels
    When Query Notifications Between Time ${start} And ${end} With limit=3
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notification Count Should Be 3 And Are Created Between ${start} And ${end}
    And totalCount Should be 6
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

# /notification/id/{id}
NotificationGET013 - Query notifications By Id
    Given Create Multiple Notifications With Different Categories And Labels
    When Query Notification By ID ${notification_ids}[2]
    Then Should Return Status Code "200" And notification
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal  ${content}[notification][id]  ${notification_ids}[2]
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

# /notification/subscription/name/{name}
NotificationGET014 - Query notifications that subscribed categories by subscription
    Given Create Multiple Subscriptions With Different Categories And Labels
    And Set Test Variable  ${specified_subscription}  ${subscription_names}[0]
    And Create Multiple Notifications With Different Categories And Labels
    When Query All Notifications By Specified Subscription Name  ${specified_subscription}
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 4
    And totalCount Should be 4
    And Only Notifications That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  @{subscription_names}

NotificationGET015 - Query notifications that subscribed labels by subscription
    Given Create Multiple Subscriptions With Different Categories And Labels
    And Set Test Variable  ${specified_subscription}  ${subscription_names}[1]
    And Create Multiple Notifications With Different Categories And Labels
    When Query All Notifications By Specified Subscription Name  ${specified_subscription}
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 4
    And totalCount Should be 4
    And Only Notifications That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  @{subscription_names}

NotificationGET016 - Query notifications that subscribed labels and categories by subscription
    Given Create Multiple Subscriptions With Different Categories And Labels
    And Set Test Variable  ${specified_subscription}  ${subscription_names}[2]
    And Create Multiple Notifications With Different Categories And Labels
    When Query All Notifications By Specified Subscription Name  ${specified_subscription}
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 6
    And totalCount Should be 6
    And Only Notifications That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  @{subscription_names}

NotificationGET017 - Query notifications by subscription by offset
    Given Create Multiple Subscriptions With Different Categories And Labels
    And Set Test Variable  ${specified_subscription}  ${subscription_names}[2]
    And Create Multiple Notifications With Different Categories And Labels
    When Query All Notifications By Specified Subscription Name ${specified_subscription} With offset=2
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 4
    And totalCount Should be 6
    And Only Notifications That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  @{subscription_names}

NotificationGET018 - Query notifications by subscription by limit
    Given Create Multiple Subscriptions With Different Categories And Labels
    And Set Test Variable  ${specified_subscription}  ${subscription_names}[2]
    And Create Multiple Notifications With Different Categories And Labels
    When Query All Notifications By Specified Subscription Name ${specified_subscription} With limit=2
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[notifications]) == 2
    And totalCount Should be 6
    And Only Notifications That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  @{subscription_names}

*** Keywords ***
Create Multiple Notifications With Different Categories And Labels
    # 2 notification: category=health-check and no labels
    # 2 notification: no category and labels=[simple]
    # 2 notifications: category=health-check and labels=[simple]
    ${start}=  Get current milliseconds epoch time
    Generate 6 Notifications Sample
    Remove From Dictionary  ${notification}[0][notification]  labels
    Remove From Dictionary  ${notification}[1][notification]  labels
    Remove From Dictionary  ${notification}[2][notification]  category
    Remove From Dictionary  ${notification}[3][notification]  category
    Create Notification ${notification}
    ${end}=  Get current milliseconds epoch time
    Set Test Variable  ${start}  ${start}
    Set Test Variable  ${end}  ${end}
    sleep  1500ms   # sleep to avoid deleting transmissions failing

Create Multiple Subscriptions With Different Categories And Labels
    ${new_categories}=  Create List  new_category
    ${new_labels}=  Create List  new_label
    Generate 3 Subscriptions Sample
    Set To Dictionary  ${subscription}[0][subscription]  categories=@{new_categories}  # labels=[simple]
    Set To Dictionary  ${subscription}[1][subscription]  labels=@{new_labels}          # categories=[health-check]
    Create Subscription ${subscription}

Notification Count Should Be ${number} And Are Created Between ${start} And ${end}
    ${count}=  Evaluate  len(${content}[notifications])
    Should Be Equal As Integers  ${count}  ${number}
    FOR  ${index}  IN RANGE  0  ${count}
        Should Be True  ${end}>=${content}[notifications][${index}][created]>=${start}
    END

Only Notifications That Subscribed By The Subscription Should Be Listed
    ${notifications}=  Set Variable  ${content}[notifications]
    FOR  ${index}  IN RANGE  0  len(${notifications})
        ${keys}=  Get Dictionary Keys  ${notifications}[${index}]
        ${check_category}=  Run Keyword And Return Status  Run Keyword If  "category" in ${keys}  Should Be True  health-check  ${notifications}[${index}][category]
        ${check_label}=  Run Keyword And Return Status  Run Keyword If  "labels" in ${keys}  List Should Contain Value  ${notifications}[${index}][labels]  simple
        Run Keyword If  ${check_category}==${False} and ${check_label}==${False}  Fail  Contain Not Matched notifications
    END
