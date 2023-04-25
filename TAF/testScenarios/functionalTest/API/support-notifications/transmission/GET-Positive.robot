*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/cleanupAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                   AND  Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True   # Start HTTP Server
Suite Teardown  Run Keywords  Run Teardown Keywords
...                      AND  Terminate All Processes  kill=True

*** Variables ***
${SUITE}          Support Notifications Transmission GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-transmission-get-positive.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /transmission/all
TransmissionGET001 - Query all transmissions that transmissions are less then 20
    Given Create Subscriptions And Notifications Make Less Than 20 Transmission Created
    When Query All Transmissions
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Should be 4
    And Should Be True  len(${content}[transmissions]) == 4
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

TransmissionGET002 - Query all transmissions that transmissions are more then 20
    # Generate more than 20 transmissions
    Given Create Subscriptions And Notifications Make More Than 20 Transmission Created
    When Query All Transmissions
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[transmissions]) == 20
    And totalCount Should be 24
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

TransmissionGET003 - Query all transmissions by offset
    Given Create Subscriptions And Notifications Make Less Than 20 Transmission Created
    When Query All Transmissions With offset=1
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[transmissions]) == 3
    And totalCount Should be 4
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

TransmissionGET004 - Query all transmissions by limit
    Query All Subscriptions
    Given Create Subscriptions And Notifications Make Less Than 20 Transmission Created
    When Query All Transmissions With limit=2
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[transmissions]) == 2
    And totalCount Should be 4
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

# /transmission/status/{status}
TransmissionGET005 - Query transmissions with specified status
    Query All Subscriptions
    Given Create Subscriptions And Notifications Make Less Than 20 Transmission Created
    And Query All Transmissions
    When Query Transmissions By Specified Status  SENT
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Should be 2
    And Should Be True  len(${content}[transmissions]) == 2
    And Transmissions Should Be Linked To Specified Status: SENT
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

TransmissionGET006 - Query transmissions with specified status by offset
    Query All Subscriptions
    Given Create Subscriptions And Notifications Make Less Than 20 Transmission Created
    When Query Transmissions By Specified Status SENT With offset=1
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[transmissions]) == 1
    And totalCount Should be 2
    And Transmissions Should Be Linked To Specified Status: SENT
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

TransmissionGET007 - Query transmissions with specified status by limit
    Query All Subscriptions
    Given Create Subscriptions And Notifications Make Less Than 20 Transmission Created
    When Query Transmissions By Specified Status SENT With limit=1
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[transmissions]) == 1
    And totalCount Should be 2
    And Transmissions Should Be Linked To Specified Status: SENT
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

*** Keywords ***
Create Subscriptions And Notifications Make Less Than 20 Transmission Created
    Generate 2 Subscriptions Sample With REST Channel
    ${resendLimit}  Convert to Integer  1
    Set To Dictionary  ${subscription}[0][subscription]  resendLimit=${resendLimit}
    Set To Dictionary  ${subscription}[0][subscription]  resendInterval=1s
    Set To Dictionary  ${subscription}[0][subscription][channels][0]  host=${DOCKER_HOST_IP}
    Set To Dictionary  ${subscription}[1][subscription]  resendLimit=${resendLimit}
    Create Subscription ${subscription}
    Generate 2 Notifications Sample
    Remove From Dictionary  ${notification}[0][notification]  category
    Set To Dictionary  ${notification}[1][notification]  severity=CRITICAL
    Create Notification ${notification}
    sleep  1s  # Waiting for transmission status ESCALATED

Create Subscriptions And Notifications Make More Than 20 Transmission Created
    Generate 3 Subscriptions Sample
    ${resendLimit}  Convert to Integer  1
    Set To Dictionary  ${subscription}[0][subscription]  resendLimit=${resendLimit}
    Set To Dictionary  ${subscription}[0][subscription]  resendInterval=1s
    Set To Dictionary  ${subscription}[0][subscription][channels][0]  host=${DOCKER_HOST_IP}
    Set To Dictionary  ${subscription}[1][subscription]  resendLimit=${resendLimit}
    Create Subscription ${subscription}
    Generate 8 Notifications Sample
    Remove From Dictionary  ${notification}[0][notification]  category
    Set To Dictionary  ${notification}[1][notification]  severity=CRITICAL
    Create Notification ${notification}
    sleep  2s  # Waiting for transmission status ESCALATED

Transmissions Should Be Linked To Specified Status: ${status}
    ${transmissions}=  Set Variable  ${content}[transmissions]
    FOR  ${item}  IN  @{transmissions}
        Should Be Equal As Strings  ${item}[status]  ${status}
    END

