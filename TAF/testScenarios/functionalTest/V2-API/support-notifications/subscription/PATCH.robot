*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags

*** Variables ***
${SUITE}          Support Notifications Subscription PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-patch.log
${url}            ${supportNotificationsUrl}
${api_version}    v2

*** Test Cases ***
SubscriptionPATCH001 - Update subscription
    Given Create Multiple Subscriptions
    When Update Subscriptions
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Subscription Data Should Be Updated

ErrSubscriptionPATCH001 - Update subscription with non-existed name
    Given Create Multiple Subscriptions
    When Update Subscriptions With Non-existed Name
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPATCH002 - Update subscription with empty name
    Given Create Multiple Subscriptions
    When Update Subscriptions With Empty Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPATCH003 - Update subscription with empty channels
    Given Create Multiple Subscriptions
    When Update Subscriptions With Empty Channels
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPATCH004 - Update subscription with empty receiver
    Given Create Multiple Subscriptions
    When Update Subscriptions With Empty Receiver
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPATCH005 - Update subscription with empty categories and labels
    Given Create Multiple Subscriptions
    When Update Subscriptions With Empty Categories And Empty Labels
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionPATCH006 - Update subscription with invalid ResendInterval
    Given Create Multiple Subscriptions
    When Update Subscriptions With Invalid ResendInterval
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
