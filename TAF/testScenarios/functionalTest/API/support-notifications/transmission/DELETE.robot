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
${SUITE}          Support Notifications Transmission DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-transmission-delete.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /transmission/age/{age}
TransmissionDELETE001 - Delete transmission by age
    # Deleted status: ACKNOWLEDGED, SENT, ESCALATED
    ${handle}=  Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True   # Start HTTP Server
    Given Create Subscriptions And Notifications
    And Query All Transmissions  # For debug
    When Delete Transmissions By Age  ${age}
    Then Should Return Status Code "202"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Processed Transmission Should Be Behind Age
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions
                ...      AND  Terminate Process  ${handle}  kill=True

ErrTransmissionDELETE001 - Delete transmission with invalid age
    Given Create Subscriptions And Notifications
    When Delete Transmissions By Age  invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

*** Keywords ***
Create Subscriptions And Notifications
    ${first_create}=  Get current milliseconds epoch time
    ${resendLimit}  Convert to Integer  2
    Generate 2 Subscriptions Sample With REST Channel
    Set To Dictionary  ${subscription}[0][subscription]  resendLimit=${resendLimit}
    Set To Dictionary  ${subscription}[0][subscription]  resendInterval=1s
    Set To Dictionary  ${subscription}[0][subscription][channels][0]  host=${DOCKER_HOST_IP}
    Set To Dictionary  ${subscription}[1][subscription]  resendLimit=${resendLimit}
    Set To Dictionary  ${subscription}[1][subscription]  resendInterval=1s
    Create Subscription ${subscription}
    Generate 2 Notifications Sample
    Remove From Dictionary  ${notification}[0][notification]  category
    Set To Dictionary  ${notification}[1][notification]  severity=CRITICAL
    Create Notification ${notification}
    sleep  2s  # Waiting for transmission status ESCALATED
    ${second_create}=  Get current milliseconds epoch time
    Generate 3 Notifications Sample
    Set To Dictionary  ${notification}[0][notification]  severity=CRITICAL
    Set To Dictionary  ${notification}[1][notification]  severity=NORMAL
    Set To Dictionary  ${notification}[2][notification]  severity=NORMAL
    Create Notification ${notification}
    sleep  2s  # Waiting for transmission status ESCALATED
    ${end}=  Get current milliseconds epoch time
    ${age}=  Evaluate  ${end}-${second_create}
    Set Test Variable  ${age}  ${age}
    Set Test Variable  ${start}  ${first_create}
    Set Test Variable  ${end}  ${second_create}

Processed Transmission Should Be Behind Age
    Query All Transmissions
    ${processed_status}  Create List  ACKNOWLEDGED  SENT  ESCALATED
    ${transmission_length}  Get Length  ${content}[transmissions]
    FOR  ${INDEX}  IN RANGE  0  ${transmission_length}
        ${status}  Set Variable  ${content}[transmissions][${INDEX}][status]
        Run Keyword If  '${status}' in ${processed_status}
        ...             Should Be True  ${content}[transmissions][${INDEX}][created] > ${end}
    END

