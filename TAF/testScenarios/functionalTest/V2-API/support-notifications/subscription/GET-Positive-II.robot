*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags

*** Variables ***
${SUITE}          Support Notifications Subscription GET Positive II Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-get-positive-II.log
${url}            ${supportNotificationsUrl}
${api_version}    v2

*** Test Cases ***
# /subscription/label/{label}
SubscriptionGET008 - Query subscriptions with specified label
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Label
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Label

SubscriptionGET009 - Query subscriptions with specified label by offset
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Label By Offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Label

SubscriptionGET010 - Query subscriptions with specified label by limit
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Label By Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Label

# /subscription/receiver/{receiver}
SubscriptionGET011 - Query subscriptions with specified receiver
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Receiver
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Receiver

SubscriptionGET012 - Query subscriptions with specified receiver by offset
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Receiver By Offset
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Receiver

SubscriptionGET013 - Query subscriptions with specified receiver by limit
    Given Create Multiple Subscriptions
    When Query Subscriptions With Specified Receiver By Limit
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Records Should Be Correct
    And Subscriptions Should Be Linked To Specified Receiver

# /subscription/name/{name}
SubscriptionGET014 - Query subscriptions by name
    Given Create Multiple Subscriptions
    When Query Subscriptions By Name
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Subscription Should Be Correct
