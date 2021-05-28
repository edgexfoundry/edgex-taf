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
# /notification/category/{category}
ErrNotificationGET001 - Query notifications by category with invalid offset range
    When Query Notifications By Category With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET002 - Query notifications by category with non-int value on offset
    When Query Notifications By Category With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET003 - Query notifications by category with non-int value on limit
    When Query Notifications By Category With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /notification/label/{label}
ErrNotificationGET004 - Query notifications by label with invalid offset range
    When Query Notifications By Label With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET005 - Query notifications by label with non-int value on offset
    When Query Notifications By Label With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET006 - Query notifications by label with non-int value on limit
    When Query Notifications By Label With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /notification/status/{status}
ErrNotificationGET007 - Query notifications by status with invalid offset range
    When Query Notifications By Status With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET008 - Query notifications by status with non-int value on offset
    When Query Notifications By Status With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET009 - Query notifications by status with non-int value on limit
    When Query Notifications By Status With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
