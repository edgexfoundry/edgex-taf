*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Notifications Subscription POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-post.log
${url}            ${supportNotificationsUrl}
${api_version}    v2

*** Test Cases ***
SubscriptionPOST001 - Create subscription
    [Tags]  SmokeTest
    Given Generate 3 Subscriptions Sample
    When Create Subscription ${subscription}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keyword And Ignore Error  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPOST001 - Create subscription with empty name
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  name=${EMPTY}
    When Create Subscription ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST002 - Create subscription with invalid name
    # https://tools.ietf.org/html/rfc3986#section-2.3, which should be ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  name=invalid name
    When Create Subscription ${subscription}
    When Create Subscription With Invalid Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST003 - Create subscription with empty channels
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  channels=@{EMPTY}
    When Create Subscription ${subscription}
    When Create Subscription With Empty Channels
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST004 - Create subscription with empty receiver
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  receiver=${EMPTY}
    When Create Subscription ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST005 - Create subscription with empty categories and labels
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  categories=${EMPTY}  labels=${EMPTY}
    When Create Subscription ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST006 - Create subscription with invalid resendInterval
    # ISO 8601 Durations format. Eg,100ms, 24h"
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  resendInterval=invalid
    When Create Subscription ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST007 - Create subscription with empty Host for REST channel
    # empty host, port and HTTPMethod
    Given Generate A Subscription Sample With REST Channel
    And Set To Dictionary  ${subscription}[0][subscription][channels][0]  host=${EMPTY}
    When Create Subscription ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST008 - Create subscription with empty Port for REST channel
    # empty host, port and HTTPMethod
    Given Generate A Subscription Sample With REST Channel
    And Remove From Dictionary  ${subscription}[0][subscription][channels][0]  port
    When Create Subscription ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPOST009 - Create subscription with empty HTTPMethod for REST channel
    # empty host, port and HTTPMethod
    Given Generate A Subscription Sample With REST Channel
    And Set To Dictionary  ${subscription}[0][subscription][channels][0]  httpMethod=${EMPTY}
    When Create Subscription ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

