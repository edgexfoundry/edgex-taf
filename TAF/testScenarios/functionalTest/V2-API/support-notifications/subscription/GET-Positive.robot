*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Notifications Subscription GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-get-positive.log
${url}            ${supportNotificationsUrl}
${api_version}    v2

*** Test Cases ***
# /subscription/all
SubscriptionGET001 - Query all subscriptions that subscriptions are less then 20
    Given Generate 3 Subscriptions Sample
    And Create Subscription ${subscription}
    When Query All Subscriptions
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 3
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET002 - Query all subscriptions that subscriptions are more then 20
    Given Generate 21 Subscriptions Sample
    And Create Subscription ${subscription}
    When Query All Subscriptions
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 20
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET003 - Query all subscriptions by offset
    Given Generate 3 Subscriptions Sample
    And Create Subscription ${subscription}
    When Query All Subscriptions With offset=1
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 2
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET004 - Query all subscriptions by limit
    Given Generate 3 Subscriptions Sample
    And Create Subscription ${subscription}
    When Query All Subscriptions With limit=2
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 2
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

# /subscription/category/{category}
SubscriptionGET005 - Query subscriptions with specified category
    ${category_list}  Create List  new_category
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  categories=@{category_list}
    And Append To List  ${subscription}[2][subscription][categories]  new_category
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Category  new_category
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 2
    And Subscriptions Should Be Linked To Specified Category: new_category
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET006 - Query subscriptions with specified category by offset
    ${category_list}  Create List  new_category
    Given Generate 5 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  categories=@{category_list}
    And Append To List  ${subscription}[2][subscription][categories]  new_category
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Category health-check With offset=1
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 3
    And Subscriptions Should Be Linked To Specified Category: health-check
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

SubscriptionGET007 - Query subscriptions with specified category by limit
    ${category_list}  Create List  new_category
    Given Generate 3 Subscriptions Sample
    And Set To Dictionary  ${subscription}[1][subscription]  categories=@{category_list}
    And Create Subscription ${subscription}
    When Query All Subscriptions By Specified Category health-check With limit=2
    Then Should Return Status Code "200" And subscriptions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[subscriptions]) == 2
    And Subscriptions Should Be Linked To Specified Category: health-check
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

*** Keywords ***
Subscriptions Should Be Linked To Specified Category: ${category}
    ${subscriptions}=  Set Variable  ${content}[subscriptions]
    FOR  ${item}  IN  @{subscriptions}
        List Should Contain Value  ${item}[categories]  ${category}
    END
