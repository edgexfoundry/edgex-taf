*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Notifications Subscription PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-subscription-patch.log

*** Test Cases ***
SubscriptionPATCH001 - Update subscription
    Given Create Subscriptions And Generate Multiple Subscriptions Sample For Updating Data
    When Update Subscriptions ${subscription}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Subscriptions Should Be Updated
    [Teardown]  Delete Multiple Subscriptions By Names  @{subscription_names}

*** Keywords ***
Create Subscriptions And Generate Multiple Subscriptions Sample For Updating Data
    Generate 4 Subscriptions Sample
    Create Subscription ${subscription}
    ${port}  Convert To Integer  8888
    ${limit}  Convert To Integer  3
    ${labels}  Create List  subscription-example  subscription-update
    ${categories}  Create List  new-category  got-error
    ${update_labels}  Create Dictionary  name=${subscription_names}[0]  labels=${labels}  resendInterval=10h
    ${update_categories}  Create Dictionary  name=${subscription_names}[1]  categories=${categories}  resendLimit=${limit}
    ${channel}  Create Dictionary  type=REST  host=localhost  port=${port}  httpMethod=PUT
    ${channels}  Create List  ${channel}
    ${update_channels}  Create Dictionary  name=${subscription_names}[2]  channels=${channels}  description=update subscription
    ${update_receiver}  Create Dictionary  name=${subscription_names}[3]  receiver=updateuser
    Generate Subscriptions  ${update_labels}  ${update_categories}  ${update_channels}  ${update_receiver}

Subscriptions Should Be Updated
    ${port}  Convert To Integer  8888
    ${limit}  Convert To Integer  3
    FOR  ${name}  IN  @{subscription_names}
        Query Subscription By Name ${name}
        Run Keyword If  "${name}" == "${subscription_names}[0]"  Run Keywords
        ...             List Should Contain Value  ${content}[subscription][labels]  subscription-update
        ...       AND   List Should Contain Value  ${content}[subscription][labels]  subscription-example
        ...       AND   Should Be Equal  ${content}[subscription][resendInterval]  10h
        ...    ELSE IF  "${name}" == "${subscription_names}[1]"  Run Keywords
        ...             List Should Contain Value  ${content}[subscription][categories]  new-category
        ...       AND   List Should Contain Value  ${content}[subscription][categories]  got-error
        ...        AND  Should Be Equal  ${content}[subscription][resendLimit]  ${limit}
        ...    ELSE IF  "${name}" == "${subscription_names}[2]"  Run Keywords
        ...             Should Be Equal  ${content}[subscription][channels][0][type]  REST
        ...        AND  Should Be Equal  ${content}[subscription][channels][0][host]  localhost
        ...        AND  Should Be Equal  ${content}[subscription][channels][0][port]  ${port}
        ...        AND  Should Be Equal  ${content}[subscription][channels][0][httpMethod]  PUT
        ...        AND  Should Be Equal  ${content}[subscription][description]  update subscription
        ...    ELSE IF  "${name}" == "${subscription_names}[3]"
        ...             Should Be Equal  ${content}[subscription][receiver]  updateuser
    END

