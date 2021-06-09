*** Settings ***
Library      uuid
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
# /transmission/id/{id}
ErrTransmissionGET010 - Query transmission with invalid id
    When Query Transmissions By Id  invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET011 - Query transmission with non-existed id
    ${random_uuid}  Evaluate  str(uuid.uuid4())
    When Query Transmissions By Id  ${random_uuid}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /transmission/start/{start}/end/{end}
ErrTransmissionGET012 - Query transmissions by start/end time fails (Invalid Start)
    ${end}  Get current milliseconds epoch time
    When Query Transmissions By Start/End Time  invalid  ${end}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET013 - Query transmissions by start/end time fails (Invalid End)
    ${start}  Get current milliseconds epoch time
    When Query Transmissions By Start/End Time  ${start}  invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET014 - Query transmissions by start/end time fails (Start>End)
    ${end}  Get current milliseconds epoch time
    ${start}  Get current milliseconds epoch time
    When Query Transmissions By Start/End Time  ${start}  ${end}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET015 - Query transmissions by start/end time with invalid offset range
    Given Create Subscriptions And Notifications
    When Query Transmissions Between Time ${start} And ${end} With offset=10
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

ErrTransmissionGET016 - Query transmissions by start/end time with non-int value on offset
    ${start}  Get current milliseconds epoch time
    ${end}  Get current milliseconds epoch time
    When Query Transmissions Between Time ${start} And ${end} With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET017 - Query transmissions by start/end time with non-int value on limit
    ${start}  Get current milliseconds epoch time
    ${end}  Get current milliseconds epoch time
    When Query Transmissions Between Time ${start} And ${end} With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Create Subscriptions And Notifications
    ${start}=  Get current milliseconds epoch time
    ${resendLimit}  Convert to Integer  1
    Generate A Subscription Sample With REST Channel
    Set To Dictionary  ${subscription}[0][subscription]  resendLimit=${resendLimit}
    Create Subscription ${subscription}
    Generate 5 Notifications Sample
    Remove From Dictionary  ${notification}[0][notification]  category
    Set To Dictionary  ${notification}[2][notification]  category=no-subscription  # no transmission generated
    Create Notification ${notification}
    Set Test Variable  ${clean_notifications}  ${notification_ids}
    ${end}=  Get current milliseconds epoch time
    Set Test Variable  ${start}  ${start}
    Set Test Variable  ${end}  ${end}

