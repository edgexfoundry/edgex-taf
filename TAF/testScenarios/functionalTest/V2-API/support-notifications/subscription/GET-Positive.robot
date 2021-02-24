*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags

*** Variables ***
${SUITE}          Support Notifications Subscription GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-get-positive.log
${url}            ${supportNotificationsUrl}
${api_version}    v2

*** Test Cases ***
# /subscription/all
SubscriptionGET001 - Query all subscriptions that subscriptions are less then 20
    Given Create Multiple Subscriptions
    When Query All Subscriptions
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be The Same As Created

SubscriptionGET002 - Query all subscriptions that subscriptions are more then 20
    Given Create Multiple Subscriptions
    When Query All Subscriptions
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Equal To 20

SubscriptionGET003 - Query all subscriptions by offset
    Given Create Multiple Subscriptions
    When Query All Subscriptions By Offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct

SubscriptionGET004 - Query all subscriptions by limit
    Given Create Multiple Subscriptions
    When Query All Subscriptions By Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct

# /subscription/category/{category}
SubscriptionGET005 - Query subscriptions with specified category
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Category
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Category

SubscriptionGET006 - Query subscriptions with specified category by offset
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Category By Offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Category

SubscriptionGET007 - Query subscriptions with specified category by limit
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Category By Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Category

