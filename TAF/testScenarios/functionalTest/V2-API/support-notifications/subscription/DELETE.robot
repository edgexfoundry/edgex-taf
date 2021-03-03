*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags

*** Variables ***
${SUITE}          Support Notifications Subscription DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-delete.log
${url}            ${supportNotificationsUrl}
${api_version}    v2

*** Test Cases ***
# /subscription/name/{name}
SubscriptionDELETE001 - Delete subscription by name
    Given Create A Subscription
    When Delete Subscription By Name
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Subscription Should Not Be Found

ErrSubscriptionDELETE001 - Delete subscription by name with empty name
    When Delete Subscription By Name With Empty Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionDELETE001 - Delete subscription by name with non-existed name
    When Delete Subscription By Name With Non-existed Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms


