*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Notifications Subscription DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-delete.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /subscription/name/{name}
SubscriptionDELETE001 - Delete subscription by name
    Given Generate A Subscription Sample With EMAIL Channel
    And Set To Dictionary  ${subscription}[0][subscription]  name=subscription-test
    And Create Subscription ${subscription}
    When Delete Subscription By Name subscription-test
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Subscription subscription-test Should Not Be Found

ErrSubscriptionDELETE001 - Delete subscription by name with non-existed name
    When Delete Subscription By Name non-existed
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Subscription ${name} Should Not Be Found
    Query Subscription By Name ${name}
    Should Return Status Code "404"

