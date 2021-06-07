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
${SUITE}          Support Notifications Notification GET Negative III Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-get-negative-III.log


*** Test Cases ***
# /notification/subscription/name/{name}
ErrNotificationGET018 - Query notifications by subscription name with invalid offset range
    Given Generate A Subscription Sample With REST Channel
    And Create Subscription ${subscription}
    And Generate 3 Notifications Sample
    And Create Notification ${notification}
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Subscription Name ${subscription_names}[0] With offset=4
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Subscription By Name ${subscription_names}[0]

ErrNotificationGET019 - Query notifications by subscription name with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Subscription Name subscription_123 With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET020 - Query notifications by subscription name with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Subscription Name subscription_123 With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
