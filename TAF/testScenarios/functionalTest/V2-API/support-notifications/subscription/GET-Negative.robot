*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags

*** Variables ***
${SUITE}          Support Notifications Subscription GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-get-negative.log
${url}            ${supportNotificationsUrl}
${api_version}    v2

*** Test Cases ***
# /subscription/all
ErrSubscriptionGET001 - Query all subscriptions with non-int value on offset
    When Query All Subscriptions With Invalid Offset
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionGET002 - Query all subscriptions with non-int value on limit
    When Query All Subscriptions With Invalid Limit
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /subscription/category/{category}
ErrSubscriptionGET003 - Query subscriptions with specified category and non-int value on offset
    When Query Subscriptions With Specified Category And Invalid Offset
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionGET004 - Query subscriptions with specified category and non-int value on limit
    When Query Subscriptions With Specified Category And Invalid Limit
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /subscription/label/{label}
ErrSubscriptionGET005 - Query subscriptions with specified label and non-int value on offset
    When Query Subscriptions With Specified Label And Invalid Offset
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionGET006 - Query subscriptions with specified label and non-int value on limit
    When Query Subscriptions With Specified Label And Invalid Limit
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /subscription/receiver/{receiver}
ErrSubscriptionGET007 - Query subscriptions with specified receiver and non-int value on offset
    When Query Subscriptions With Specified Receiver And Invalid Offset
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSubscriptionGET008 - Query subscriptions with specified receiver and non-int value on limit
    When Query Subscriptions With Specified Receiver And Invalid Limit
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /subscription/name/{name}
ErrSubscriptionGET009 - Query subscriptions with non-existed name
    When Query Subscriptions With Non-existed Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
