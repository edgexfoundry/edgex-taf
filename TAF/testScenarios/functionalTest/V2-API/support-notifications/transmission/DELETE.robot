*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Notifications Transmission DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-transmission-delete.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /transmission/age/{age}
TransmissionDELETE001 - Delete transmission by age
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Delete Transmission By Age
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmission Status With Status PROCESSED And Under Age Should Not Be Found

ErrTransmissionDELETE001 - Delete transmission with invalid age
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Delete Transmission By Invalid Age
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms


