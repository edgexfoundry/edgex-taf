*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Notifications Subscription GET Positive II Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-get-positive-II.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /subscription/label/{label}
SubscriptionGET008 - Query subscriptions with specified label
    ${label_list}  Create List  new_list
    Given Generate 5 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  labels=@{label_list}
    And Append To List  ${subscription}[2][subscription][labels]  new_list
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Label  new_list
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 2
    And Subscriptions Should Be Linked To Specified Label: new_list
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET009 - Query subscriptions with specified label by offset
    ${label_list}  Create List  new_list
    Given Generate 5 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  labels=@{label_list}
    And Append To List  ${subscription}[2][subscription][labels]  new_list
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Label simple With offset=1
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 3
    And Subscriptions Should Be Linked To Specified Label: simple
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET010 - Query subscriptions with specified label by limit
    ${label_list}  Create List  new_list
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  labels=@{label_list}
    And Append To List  ${subscription}[2][subscription][labels]  new_list
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Label simple With limit=2
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 2
    And Subscriptions Should Be Linked To Specified Label: simple
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

# /subscription/receiver/{receiver}
SubscriptionGET011 - Query subscriptions with specified receiver
    Given Generate 5 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  receiver=admin
    And Set To Dictionary  ${subscription}[2][subscription]  receiver=common
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Receiver  tafuser
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 3
    And Subscriptions Should Be Linked To Specified Receiver: tafuser
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET012 - Query subscriptions with specified receiver by offset
    Given Generate 5 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  receiver=admin
    And Set To Dictionary  ${subscription}[2][subscription]  receiver=common
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Receiver tafuser With offset=1
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 2
    And Subscriptions Should Be Linked To Specified Receiver: tafuser
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET013 - Query subscriptions with specified receiver by limit
    Given Generate 5 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  receiver=admin
    And Set To Dictionary  ${subscription}[2][subscription]  receiver=common
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Receiver tafuser With limit=2
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 2
    And Subscriptions Should Be Linked To Specified Receiver: tafuser
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

# /subscription/name/{name}
SubscriptionGET014 - Query subscriptions by name
    Given Generate A Subscription Sample With EMAIL Channel
    And Set To Dictionary  ${subscription}[0][subscription]  name=subscription-test
    And Create Subscription ${subscription}
    When Query Subscription By Name subscription-test
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Strings  subscription-test  ${content}[subscription][name]
    [Teardown]  Delete Subscription By Name subscription-test

*** Keywords ***
Subscriptions Should Be Linked To Specified Label: ${label}
    ${subscriptions}=  Set Variable  ${content}[subscriptions]
    FOR  ${item}  IN  @{subscriptions}
        List Should Contain Value  ${item}[labels]  ${label}
    END

Subscriptions Should Be Linked To Specified Receiver: ${receiver}
    ${subscriptions}=  Set Variable  ${content}[subscriptions]
    FOR  ${item}  IN  @{subscriptions}
        Log  ${item}
        Should Be Equal As Strings  ${item}[receiver]  ${receiver}
    END

