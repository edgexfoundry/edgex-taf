*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/cleanupAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Notifications Notification DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-delete.log

*** Test Cases ***
NotificationDELETE001 - Delete notification by id
    Given Create Subscription Sample
    And Generate A Notification Sample With serverity NORMAL
    And Create Notification ${notification}
    When Delete Notification By ID ${notification_ids}[0]
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found  ${notification_ids}[0]
    And The Associated Transmissions Should Not Be Found
    [Teardown]  Delete Subscription By Name ${subscription_names}[0]

NotificationDELETE002 - Delete notification by age
    Given Create Subscriptions And Notifications For Different Status
    When Delete Notifications By Age
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Should Not Be Found  @{notification_ids}  # all notifications will become PROCESSED once created
    And The Associated Transmissions Should Not Be Found
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Multiple Subscriptions By Names  ${subscription_names}[0]  ESCALATION

ErrNotificationDELETE001 - Delete notification by non-existed id
    When Delete Notification By ID Non-Existed
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrNotificationDELETE002 - Delete notification with invalid age
    When Run Keyword And Expect Error  *  Delete Notifications By Age  Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Create Subscription Sample
    Generate A Subscription Sample With REST Channel
    Create Subscription ${subscription}

Create Subscriptions And Notifications For Different Status
    Create ESCALATION Subscription Sample With REST Channel
    Generate A Subscription Sample With EMAIL Channel
    Set To Dictionary  ${subscription}[0][subscription]  resendInterval=1s
    Create Subscription ${subscription}
    Generate 3 Notifications Sample
    Set To Dictionary  ${notification}[0][notification]  severity=CRITICAL  # resend fails and generate ESCALATED notification
    Set To Dictionary  ${notification}[1][notification]  severity=NORMAL
    Set To Dictionary  ${notification}[2][notification]  severity=MINOR
    Create Notification ${notification}
    sleep  3s  # for resending

Notifications Should Not Be Found
    [Arguments]  @{notification_ids}
    FOR  ${id}  IN  @{notification_ids}
      Run Keyword And Expect Error  *  Query Notification By ID ${id}
      Should Return Status Code "404"
    END

The Associated Transmissions Should Not Be Found
    Query Transmissions By Specified Subscription  ${subscription_names}[0]
    ${transmissions}=  Set Variable  ${content}[transmissions]
    FOR  ${index}  IN RANGE  0  len(${transmissions})
      List Should Not Contain Value  ${notification_ids}  ${transmissions}[${index}][notificationId]
    END
