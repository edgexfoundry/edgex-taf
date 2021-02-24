*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags

*** Variables ***
${SUITE}          Support Notifications Subscription POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-post.log
${url}            ${supportNotificationsUrl}
${api_version}    v2

*** Test Cases ***
SubscriptionPOST001 - Create subscription
    When Create Multiple Subscriptions
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST001 - Create subscription with empty name
    When Create Subscription With Empty Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST002 - Create subscription with invalid name
    # https://tools.ietf.org/html/rfc3986#section-2.3, which should be ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~
    When Create Subscription With Invalid Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST003 - Create subscription with empty channels
    When Create Subscription With Empty Channels
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST004 - Create subscription with empty receiver
    When Create Subscription With Empty Receiver
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST005 - Create subscription with empty categories and labels
    When Create Subscription With Empty Categories And Empty Labels
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST006 - Create subscription with invalid resendInterval
    # ISO 8601 Durations format. Eg,100ms, 24h"
    When Create Subscription With Invalid ResendInterval
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
