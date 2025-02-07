*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Notifications Notification PUT Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-put-positive.log

*** Test Cases ***
# /notification/acknowledge/ids/{ids}
NotificationPUT001 - Update multiple notifications ack status to true
    Given Create Multiple Notifications With Different Categories
    And Set Notification Lists
    When Update Notifications Ack Status to True By IDs  @{id_to_set_ack}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notification ${id_to_set_ack} Ack Status Should Be ${true}
    And Notification ${id_not_set_ack} Ack Status Should Not Be ${true}
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

# /notification/unacknowledge/ids/{ids}
NotificationPUT002 - Update multiple notifications ack status to false
    Given Create Multiple Notifications With Different Categories
    And Update Notifications Ack Status to True By IDs  @{notificationIds}
    And Set Notification Lists
    When Update Notifications Ack Status to False By IDs  @{id_to_set_ack}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notification ${id_to_set_ack} Ack Status Should Be ${false}
    And Notification ${id_not_set_ack} Ack Status Should Not Be ${false}
    [Teardown]  Delete Multiple Notifications By IDs  @{notification_ids}

*** Keywords ***
Set Notification Lists
    ${id_to_set_ack}  Create List  ${notification_ids}[1]  ${notification_ids}[2]
    ${id_not_set_ack}  Create List  ${notification_ids}[0]  ${notification_ids}[3]  ${notification_ids}[4]
    Set Test Variable  ${id_to_set_ack}  ${id_to_set_ack}
    Set Test Variable  ${id_not_set_ack}  ${id_not_set_ack}

Notification ${ids} Ack Status Should Be ${bool}
    FOR  ${notificationId}  IN  @{ids}
        Query Notification By ID ${notificationId}
        Should Be Equal  ${content}[notification][acknowledged]  ${bool}
    END

Notification ${ids} Ack Status Should Not Be ${bool}
    FOR  ${notificationId}  IN  @{ids}
        Query Notification By ID ${notificationId}
        Should Not Be Equal  ${content}[notification][acknowledged]  ${bool}
    END
