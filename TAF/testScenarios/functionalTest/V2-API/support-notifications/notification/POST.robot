*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags   v2-api

*** Variables ***
${SUITE}          Support Notifications Notification POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-post.log

*** Test Cases ***
NotificationPOST001 - Create notification
    Given Generate 3 Notifications Sample
    And Remove From Dictionary  ${notification}[0][notification]  category  # only contain labels
    And Remove From Dictionary  ${notification}[1][notification]  labels    # only contain category
    When Create Notification ${notification}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

ErrNotificationPOST001 - Create notification with empty content
    Given Generate 3 Notifications Sample
    And Set To Dictionary  ${notification}[0][notification]  content=${EMPTY}
    When Create Notification ${notification}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST002 - Create notification with empty sender
    Given Generate 3 Notifications Sample
    And Set To Dictionary  ${notification}[1][notification]  sender=${EMPTY}
    When Create Notification ${notification}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST003 - Create notification with invalid sender
    Given Generate 3 Notifications Sample
    And Set To Dictionary  ${notification}[2][notification]  sender=test@123
    When Create Notification ${notification}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST004 - Create notification with empty severity
    Given Generate 3 Notifications Sample
    And Set To Dictionary  ${notification}[0][notification]  severity=${EMPTY}
    When Create Notification ${notification}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST005 - Create notification with invalid severity
    Given Generate 3 Notifications Sample
    And Set To Dictionary  ${notification}[1][notification]  severity=Invalid
    When Create Notification ${notification}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST006 - Create notification with empty categories and labels
    Given Generate 3 Notifications Sample
    And Remove From Dictionary  ${notification}[2][notification]  category
    And Remove From Dictionary  ${notification}[2][notification]  labels
    When Create Notification ${notification}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

ErrNotificationPOST007 - Create notification with invalid status
    Given Generate 3 Notifications Sample
    And Set To Dictionary  ${notification}[1][notification]  status=Invalid
    When Create Notification ${notification}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found

*** Keywords ***
Notifications Should Not Be Found
  ${start}=  Fetch From Right  ${notification}[0][notification][description]  ${SPACE}
  ${end}=  Get current milliseconds epoch time
  Query notifications by start/end time  ${start}  ${end}
  Should Not Be True  ${content}[notifications]
