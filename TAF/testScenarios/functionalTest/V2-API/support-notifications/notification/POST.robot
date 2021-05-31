*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}          Support Notifications Notification POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-post.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
NotificationPOST001 - Create notification
    Given Generate 3 Notifications Sample
    When Create Notification ${notification}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Notifications By Id

ErrNotificationPOST001 - Create notification with empty content
    Given Generate 3 Notifications Sample
    When Create Notification With Empty Content
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST002 - Create notification with empty sender
    Given Generate 3 Notifications Sample
    When Create Notification With Empty Sender
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST003 - Create notification with invalid sender
    Given Generate 3 Notifications Sample
    When Create Notification With Invalid Sender
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST004 - Create notification with empty severity
    Given Generate 3 Notifications Sample
    When Create Notification With Empty Severity
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST005 - Create notification with invalid severity
    Given Generate 3 Notifications Sample
    When Create Notification With Invalid Severity
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST006 - Create notification with empty categories and labels
    Given Generate 3 Notifications Sample
    When Create Notification With Empty Categories And Labels
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST007 - Create notification with invalid status
    Given Generate 3 Notifications Sample
    When Create Notification With Invalid Status
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

