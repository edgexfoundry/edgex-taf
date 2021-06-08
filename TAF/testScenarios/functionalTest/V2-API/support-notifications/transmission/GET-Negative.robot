*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/cleanupAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Notifications Transmission GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-transmission-get-negative.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /transmission/all
ErrTransmissionGET001 - Query all transmissions with invalid offset range
    Given Create Subscriptions And Notifications
    When Query All Transmissions With offset=10
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

ErrTransmissionGET002 - Query all transmissions with non-int value on offset
    When Query All Transmissions With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET003 - Query all transmissions with non-int value on limit
    When Query All Transmissions With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /transmission/status/{status}
ErrTransmissionGET004 - Query transmissions by status with invalid offset range
    Given Create Subscriptions And Notifications
    When Query Transmissions By Specified Status FAILED With offset=10
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

ErrTransmissionGET005 - Query transmissions by status with non-int value on offset
    When Query Transmissions By Specified Status SENT With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET006 - Query transmissions by status with non-int value on limit
    When Query Transmissions By Specified Status SENT With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /transmission/subscription/name/{name}
ErrTransmissionGET007 - Query transmissions by subscription with invalid offset range
    Given Create Subscriptions And Notifications
    When Query Transmissions By Specified Subscription ${subscription_name} With offset=10
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

ErrTransmissionGET008 - Query transmissions by subscription with non-int value on offset
    When Query Transmissions By Specified Subscription subscription-test With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET009 - Query transmissions by subscription with non-int value on limit
    When Query Transmissions By Specified Subscription subscription-test With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Create Subscriptions And Notifications
    ${resendLimit}  Convert to Integer  1
    Generate A Subscription Sample With REST Channel
    Set To Dictionary  ${subscription}[0][subscription]  resendLimit=${resendLimit}
    Create Subscription ${subscription}
    Generate 5 Notifications Sample
    Remove From Dictionary  ${notification}[0][notification]  category
    Set To Dictionary  ${notification}[2][notification]  category=no-subscription  # no transmission generated
    Create Notification ${notification}
    Set Test Variable  ${clean_notifications}  ${notification_ids}
    Set Test Variable  ${subscription_name}  ${subscription}[0][subscription][name]
