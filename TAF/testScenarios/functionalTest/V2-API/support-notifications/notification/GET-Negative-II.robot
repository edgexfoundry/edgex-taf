*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}          Support Notifications Notification GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-get-negative.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /notification/id/{id}
ErrNotificationGET010 - Query notification with invalid id
    When Query Notification By invalid Id
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET011 - Query notification with non-existed id
    When Query Notification By Non-existed Id
    Then Should Return Status Code "440"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /notification/start/{start}/end/{end}
ErrNotificationGET012 - Query notifications by start/end time fails (Invalid Start)
    When Query Notifications By Invalid Start And End Time
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET013 - Query notifications by start/end time fails (Invalid End)
    When Query Notifications By Start And Invalid End Time
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET014 - Query notifications by start/end time fails (Start>End)
    When Query Notifications By Start And End Time
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET015 - Query notifications by start/end time with invalid offset range
    When Query Notifications By Start And End Time With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET016 - Query notifications by start/end time with non-int value on offset
    When  Query Notifications By Start And End Time With Invalid Offset
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET017 - Query notifications by start/end time with non-int value on limit
    When Query Notifications By Start And End Time With Invalid Limit
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
