*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/cleanupAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Notifications Cleanup Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-cleanup.log

*** Test Cases ***
# /cleanup
Cleanup001 - Cleanup
    Given Create Subscriptions And Notifications
    When Cleanup All Notifications And Transmissions
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Notifications And Transmissions Should Not Be Found
    [Teardown]  Delete Subscription By Name ${subscription_names}[0]

# /cleanup/age/{age}
Cleanup002 - Cleanup by age
    Given Create Subscriptions And Notifications
    When Cleanup All Notifications And Transmissions By Age  ${age}
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Notifications And Transmissions Under Age Should Not Be Found
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Subscription By Name ${subscription_names}[0]

ErrCleanup001 - Cleanup with invalid age
    Given Create Subscriptions And Notifications
    When Run Keyword And Expect Error  *  Cleanup All Notifications And Transmissions By Age  Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions By Age
                ...      AND  Delete Subscription By Name ${subscription_names}[0]


*** Keywords ***
Create Subscriptions And Notifications
    ${start}=  Get current milliseconds epoch time
    Generate A Subscription Sample With REST Channel
    Create Subscription ${subscription}
    Generate 2 Notifications Sample
    Remove From Dictionary  ${notification}[0][notification]  category
    Remove From Dictionary  ${notification}[1][notification]  labels
    Create Notification ${notification}
    Set Test Variable  ${clean_notifications}  ${notification_ids}
    sleep  500ms
    ${second_create}=  Get current milliseconds epoch time
    Generate 3 Notifications Sample
    Set To Dictionary  ${notification}[0][notification]  category=no-subscription  # no transmission generated
    Set To Dictionary  ${notification}[1][notification]  status=PROCESSED
    Set To Dictionary  ${notification}[2][notification]  status=ESCALATED
    Create Notification ${notification}
    ${end}=  Get current milliseconds epoch time
    ${age}=  Evaluate  ${end}-${second_create}
    Set Test Variable  ${age}  ${age}
    Set Test Variable  ${start}  ${start}
    Set Test Variable  ${end}  ${end}

All Notifications And Transmissions Should Not Be Found
    Query notifications by start/end time  ${start}  ${end}
    Should Not Be True  ${content}[notifications]
    Query All Transmissions
    Should Not Be True  ${content}[transmissions]

All Notifications And Transmissions Under Age Should Not Be Found
    Query Transmissions By Start/End Time  ${start}  ${end}
    ${end}=  Get current milliseconds epoch time
    ${transmissions}=  Set Variable  ${content}[transmissions]
    FOR  ${index}  IN RANGE  0  len(${transmissions})
      List Should Not Contain Value  ${clean_notifications}  ${transmissions}[${index}][notificationId]
    END
    FOR  ${id}  IN  @{clean_notifications}
      Run Keyword And Expect Error  *  Query Notification By ID ${id}
      Should Return Status Code "404"
    END
