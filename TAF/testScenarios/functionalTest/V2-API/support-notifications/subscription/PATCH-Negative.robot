*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Notifications Subscription PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-patch.log

*** Test Cases ***
ErrSubscriptionPATCH001 - Update subscription with non-existed name
    Given Generate A Subscription Sample With EMAIL Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription]  name=non-existed
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH002 - Update subscription with empty name
    Given Generate A Subscription Sample With EMAIL Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription]  name=${EMPTY}
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH003 - Update subscription with empty channels
    Given Generate A Subscription Sample With EMAIL Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription]  channels=@{EMPTY}
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH004 - Update subscription with empty receiver
    Given Generate A Subscription Sample With EMAIL Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription]  receiver=${EMPTY}
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH005 - Update subscription with empty labels and categories
    Given Generate A Subscription Sample With EMAIL Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription]  labels=@{EMPTY}
    And Set To Dictionary  ${subscription}[0][subscription]  categories=@{EMPTY}
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH006 - Update subscription with invalid resendInterval
    Given Generate A Subscription Sample With EMAIL Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription]  resendInterval=999
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH007 - Update subscription for REST channel with empty Host
    Given Generate A Subscription Sample With REST Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription][channels][0]  host=${EMPTY}
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH008 - Update subscription for REST channel with empty Port
    Given Generate A Subscription Sample With REST Channel
    And Create Subscription ${subscription}
    And Remove From Dictionary  ${subscription}[0][subscription][channels][0]  port
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH009 - Update subscription for REST channel with empty httpMethod
    Given Generate A Subscription Sample With REST Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription][channels][0]  httpMethod=${EMPTY}
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH010 - Update subscription for EMAL channel with empty recipients
    Given Generate A Subscription Sample With EMAIL Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription][channels][0]  recipients=@{EMPTY}
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

ErrSubscriptionPATCH011 - Update subscription for EMAL channel with invalid format recipients
    ${recipients}  Create List  123  456
    Given Generate A Subscription Sample With EMAIL Channel
    And Create Subscription ${subscription}
    And Set To Dictionary  ${subscription}[0][subscription][channels][0]  recipients=${recipients}
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}
