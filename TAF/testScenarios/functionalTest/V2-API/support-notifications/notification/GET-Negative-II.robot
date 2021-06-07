*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags   v2-api

*** Variables ***
${SUITE}          Support Notifications Notification GET Negative III Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-get-negative-II.log

*** Test Cases ***
# /notification/id/{id}
ErrNotificationGET010 - Query notification with invalid id
    When Run Keyword And Expect Error  *  Query Notification By ID Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET011 - Query notification with non-existed id
    ${random_uuid}=  Evaluate  str(uuid.uuid4())
    When Run Keyword And Expect Error  *  Query Notification By ID ${random_uuid}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /notification/start/{start}/end/{end}
ErrNotificationGET012 - Query notifications by start/end time fails (Invalid Start)
    ${end}=  Get current milliseconds epoch time
    When Run Keyword And Expect Error  *  Query Notifications By Start/End Time  Invalid  ${end}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET013 - Query notifications by start/end time fails (Invalid End)
    ${start}=  Get current milliseconds epoch time
    When Run Keyword And Expect Error  *  Query Notifications By Start/End Time  ${start}  Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET014 - Query notifications by start/end time fails (Start>End)
    ${start}=  Get current milliseconds epoch time
    ${end}=  Get current milliseconds epoch time
    When Run Keyword And Expect Error  *  Query Notifications By Start/End Time  ${end}  ${start}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET015 - Query notifications by start/end time with invalid offset range
    ${start}=  Get current milliseconds epoch time
    Given Generate 3 Notifications Sample
    And Create Notification ${notification}
    ${end}=  Get current milliseconds epoch time
    When Run Keyword And Expect Error  *  Query Notifications Between Time ${start} And ${end} With offset=4
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

ErrNotificationGET016 - Query notifications by start/end time with non-int value on offset
    ${start}=  Get current milliseconds epoch time
    ${end}=  Get current milliseconds epoch time
    When Run Keyword And Expect Error  *  Query Notifications Between Time ${start} And ${end} With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationGET017 - Query notifications by start/end time with non-int value on limit
    ${start}=  Get current milliseconds epoch time
    ${end}=  Get current milliseconds epoch time
    When Run Keyword And Expect Error  *  Query Notifications Between Time ${start} And ${end} With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
