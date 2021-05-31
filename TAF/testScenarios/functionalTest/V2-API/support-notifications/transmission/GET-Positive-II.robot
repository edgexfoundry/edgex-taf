*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}          Support Notifications Transmission GET Positive II Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-transmission-get-positive-II.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /transmission/start/{start}/end/{end}
TransmissionGET008 - Query transmissions with time range
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions By Start And End Time
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmissions Count Should Be Correct
    And Transmissions Is Created Between Start And End Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

TransmissionGET009 - Query transmissions with time range by offset
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions By Start And End Time With offset
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmissions Count Should Be Correct With Offset
    And Transmissions Is Created Between Start And End Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

TransmissionGET010 - Query transmissions with time range by limit
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions By Start And End Time With Limit
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmissions Count Should Be Correct With Limit
    And Transmissions Is Created Between Start And End Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

# /transmission/id/{id}
TransmissionGET011 - Query transmissions By Id
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query Transmission By Id
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only The Queried Transmission Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

# /transmission/subscription/name/{name}
TransmissionGET012 - Query transmissions by subscription
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query Transmissions By Subscription Name
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Transmissions With Specified Subscription Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions
