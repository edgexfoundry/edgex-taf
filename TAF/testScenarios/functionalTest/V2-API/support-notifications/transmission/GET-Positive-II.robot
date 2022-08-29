*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Resource     TAF/testCaseModules/keywords/support-notifications/cleanupAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Notifications Transmission GET Positive II Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-transmission-get-positive-II.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /transmission/start/{start}/end/{end}
TransmissionGET008 - Query transmissions with time range
    Given Create Subscriptions And Notifications
    When Query Transmissions By Start/End Time  ${start}  ${end}
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmission Count Should Be 4 And Are Created Between ${start} And ${end}
    And totalCount Should be 4
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

TransmissionGET009 - Query transmissions with time range by offset
    Given Create Subscriptions And Notifications
    When Query Transmissions Between Time ${start} And ${end} With offset=1
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmission Count Should Be 3 And Are Created Between ${start} And ${end}
    And totalCount Should be 4
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

TransmissionGET010 - Query transmissions with time range by limit
    Given Create Subscriptions And Notifications
    When Query Transmissions Between Time ${start} And ${end} With limit=2
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmission Count Should Be 2 And Are Created Between ${start} And ${end}
    And totalCount Should be 4
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

# /transmission/id/{id}
TransmissionGET011 - Query transmissions By Id
    Given Create A Subscriptions And Notifications
    And Get Transmission Id
    When Query Transmissions By Id  ${transmission_id}
    Then Should Return Status Code "200" And transmission
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal  ${content}[transmission][id]  ${transmission_id}
    And Should Be Equal As Integers  ${content}[transmission][resendCount]  1
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions
                ...      AND  Set Writable configs: resendInterval=5s and resendLimit=2

# /transmission/subscription/name/{name}
TransmissionGET012 - Query transmissions by subscription
    Given Create Subscriptions And Notifications
    When Query Transmissions By Specified Subscription  ${subscription_names}[0]
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Transmission That Subscribed By The Subscription Should Be Listed
    [Teardown]  Run Keywords  Delete Multiple Subscriptions By Names  @{subscription_names}
                ...      AND  Cleanup All Notifications And Transmissions

*** Keywords ***
Create Subscriptions And Notifications
    ${start}=  Get current milliseconds epoch time
    ${resendLimit}  Convert to Integer  1
    Generate A Subscription Sample With REST Channel
    Set To Dictionary  ${subscription}[0][subscription]  resendLimit=${resendLimit}
    Create Subscription ${subscription}
    Generate 5 Notifications Sample
    Remove From Dictionary  ${notification}[0][notification]  category
    Set To Dictionary  ${notification}[2][notification]  category=no-subscription  # no transmission generated
    Create Notification ${notification}
    Set Test Variable  ${clean_notifications}  ${notification_ids}
    ${end}=  Get current milliseconds epoch time
    Set Test Variable  ${start}  ${start}
    Set Test Variable  ${end}  ${end}

Transmission Count Should Be ${number} And Are Created Between ${start} And ${end}
    ${count}=  Evaluate  len(${content}[transmissions])
    Should Be Equal As Integers  ${count}  ${number}
    FOR  ${index}  IN RANGE  0  ${count}
        Should Be True  ${end}>=${content}[transmissions][${index}][created]>=${start}
    END

Create A Subscriptions And Notifications
    Set Writable configs: resendInterval=2s and resendLimit=1
    Generate A Subscription Sample With REST Channel
    Remove From Dictionary  ${subscription}[0][subscription]  resendLimit  resendInterval  # use Writable configs
    Create Subscription ${subscription}
    Generate 1 Notifications Sample
    Set To Dictionary  ${notification}[0][notification]  severity=CRITICAL
    Create Notification ${notification}
    sleep  3s  # Waiting for the resend process to finish

Set Writable configs: resendInterval=${resendInterval} and resendLimit=${resendLimit}
    ${path}=  Set variable  /v1/kv/edgex/core/${CONSUL_CONFIG_VERSION}/support-notifications/Writable
    Update Service Configuration On Consul  ${path}/ResendInterval  ${resendInterval}
    Update Service Configuration On Consul  ${path}/ResendLimit  ${resendLimit}

Get Transmission Id
    Query All Transmissions
    ${transmission_id}  Set Variable  ${content}[transmissions][0][id]
    Set Test Variable  ${transmission_id}

Only Transmission That Subscribed By The Subscription Should Be Listed
    ${transmissions}=  Set Variable  ${content}[transmissions]
    FOR  ${index}  IN RANGE  0  len(${transmissions})
        ${keys}=  Get Dictionary Keys  ${transmissions}[${index}]
        ${check_category}=  Run Keyword And Return Status  Run Keyword If  "category" in ${keys}  Should Be True  health-check  ${transmissions}[${index}][category]
        ${check_label}=  Run Keyword And Return Status  Run Keyword If  "labels" in ${keys}  List Should Contain Value  ${transmissions}[${index}][labels]  simple
        Run Keyword If  ${check_category}==${False} and ${check_label}==${False}  Fail  Contain Not Matched Transmissions
    END
