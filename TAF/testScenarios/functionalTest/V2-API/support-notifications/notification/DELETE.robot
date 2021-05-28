*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}          Support Notifications Notification DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-delete.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
NotificationDELETE001 - Delete notification by id
    Given Create A Notification
    When Delete Notification By Id
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found
    And The Associated Transmissions Should Not Be Found

NotificationDELETE002 - Delete notification by age
    Given Create Multiple Notifications With Different Status
    When Delete Notification By Age
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Notifications With Status PROCESSED Should Not Be Found
    And The Associated Transmissions Should Not Be Found

ErrNotificationDELETE001 - Delete notification by non-existed id
    When Delete Notification By Non-existed Id
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationDELETE002 - Delete notification with invalid age
    When Delete Notification With Invalid Age
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
