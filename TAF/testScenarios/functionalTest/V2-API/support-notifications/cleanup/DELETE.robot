*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Notifications Cleanup Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-cleanup.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /cleanup
Cleanup001 - Cleanup
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Cleanup All Notifications And Transmissions
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Notifications And Transmissions Should Not Be Found

# /cleanup/age/{age}
Cleanup002 - Cleanup by age
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Cleanup All Notifications And Transmissions By Age
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Notifications And Transmissions Under Age Should Not Be Found

ErrCleanup001 - Delete transmission with invalid age
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Cleanup All Notifications And Transmissions By Invalid Age
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms


