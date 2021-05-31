*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}          Support Notifications Transmission GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-transmission-get-positive.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /transmission/all
TransmissionGET001 - Query all transmissions that transmissions are less then 20
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Transmission Should Be Found
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

TransmissionGET002 - Query all transmissions that transmissions are more then 20
    # Generate more than 20 transmissions
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only 20 Transmissions Should Be Found
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

TransmissionGET003 - Query all transmissions by offset
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions With offset=1
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmission Count Is Correct
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

TransmissionGET004 - Query all transmissions by limit
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions With limit=2
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmission Count Is Correct
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

# /transmission/status/{status}
TransmissionGET005 - Query transmissions with specified status
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions By Specified Status
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmissions Count Should Be Correct
    And Only Transmissions With The Specified Status Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

TransmissionGET006 - Query transmissions with specified status by offset
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions By Specified Status With offset
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmissions Count Should Be Correct With Offset
    And Only Transmissions With The Specified Status Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

TransmissionGET007 - Query transmissions with specified status by limit
    Given Create Subscriptions
    And Create Notifications Contain Category Or Label Has Subscribed
    When Query All Transmissions By Specified Status With Limit
    Then Should Return Status Code "200" And transmissions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Transmissions Count Should Be Correct With Limit
    And Only Transmissions With The Specified Status Should Be Listed
    [Teardown]  Run Keywords  Cleanup All Notifications And Transmissions
                ...      AND  Delete Subscriptions

