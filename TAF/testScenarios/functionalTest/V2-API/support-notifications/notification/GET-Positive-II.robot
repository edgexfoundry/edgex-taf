*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}          Support Notifications Notification GET Positive II Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-get-positive-II.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /notification/start/{start}/end/{end}
NotificationGET010 - Query notifications with time range
    Given Create Multiple Notifications
    When Query All Notifications By Start And End Time
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct
    And Notifications Is Created Between Start And End Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

NotificationGET011 - Query notifications with time range by offset
    Given Create Multiple Notifications
    When Query All Notifications By Start And End Time With offset
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct With Offset
    And Notifications Is Created Between Start And End Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

NotificationGET012 - Query notifications with time range by limit
    Given Create Multiple Notifications
    When Query All Notifications By Start And End Time With Limit
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct With Limit
    And Notifications Is Created Between Start And End Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

# /notification/id/{id}
NotificationGET013 - Query notifications By Id
    Given Create Multiple Notifications
    When Query Notification By Id
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only The Queried Notification Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

# /notification/subscription/name/{name}
NotificationGET014 - Query notifications that subscribed categories by subscription
    Given Create A Subscription With Categories
    And Create Multiple Notifications And Some Of Contain Same Category With Subscription
    When Query All Notifications By The Created Subscription Name
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Notifications That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Delete Multiple Notifications By Ids
                ...      AND  Delete Subscription By Name

NotificationGET015 - Query notifications that subscribed labels by subscription
    Given Create A Subscription With Labels
    And Create Multiple Notifications And Some Of Contain Same Label With Subscription
    When Query All Notifications By The Created Subscription Name
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Notifications That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Delete Multiple Notifications By Ids
                ...      AND  Delete Subscription By Name

NotificationGET016 - Query notifications that subscribed labels and categories by subscription
    Given Create A Subscription With Labels And Categories
    And Create Multiple Notifications And Some of Contain Same Label And Categories With Subscription
    When Query All Notifications By The Created Subscription Name
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Notifications That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Delete Multiple Notifications By Ids
                ...      AND  Delete Subscription By Name

