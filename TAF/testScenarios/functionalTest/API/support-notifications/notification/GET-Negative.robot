*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Notifications Notification GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-get-negative.log
${category}       health-check
${label}          simple

*** Test Cases ***
# /notification/category/{category}
ErrNotificationGET001 - Query notifications by category with invalid offset range
    Given Generate 3 Notifications Sample
    And Create Notification ${notification}
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Category ${category} With offset=4
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

ErrNotificationGET002 - Query notifications by category with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Category ${category} With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET003 - Query notifications by category with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Category ${category} With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /notification/label/{label}
ErrNotificationGET004 - Query notifications by label with invalid offset range
    Given Generate 3 Notifications Sample
    And Create Notification ${notification}
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Label ${label} With offset=4
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

ErrNotificationGET005 - Query notifications by label with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Label ${label} With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET006 - Query notifications by label with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Notifications By Specified Label ${label} With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /notification/status/{status}
ErrNotificationGET007 - Query notifications by status with invalid offset range
    Given Generate 3 Notifications Sample
    And Create Notification ${notification}
    When Run Keyword And Expect Error  *  Query All Notifications By Status PROCESSED With offset=4
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

ErrNotificationGET008 - Query notifications by status with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Notifications By Status PROCESSED With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET009 - Query notifications by status with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Notifications By Status PROCESSED With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

