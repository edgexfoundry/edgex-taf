*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}          Support Notifications Notification GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-notification-get-positive.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /notification/category/{category}
NotificationGET001 - Query notifications with specified category
    Given Create Multiple Notifications With Different Categories
    When Query All Notifications By Specified Category
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct
    And Only Notifications With The Specified Category Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

NotificationGET002 - Query notifications with specified category by offset
    Given Create Multiple Notifications With Different Categories
    When Query All Notifications By Specified Category With offset
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct With Offset
    And Only Notifications With The Specified Category Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

NotificationGET003 - Query notifications with specified category by limit
    Given Create Multiple Notifications With Different Categories
    When Query All Notifications By Specified Category With Limit
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct With Limit
    And Only Notifications With The Specified Category Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

# /notification/label/{label}
NotificationGET004 - Query notifications with specified label
    Given Create Multiple Notifications With Different Labels
    When Query All Notifications By Specified Label
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct
    And Only Notifications With The Specified Label Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

NotificationGET005 - Query notifications with specified label by offset
    Given Create Multiple Notifications With Different Labels
    When Query All Notifications By Specified Label With offset
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct With Offset
    And Only Notifications With The Specified Label Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

NotificationGET006 - Query notifications with specified label by limit
    Given Create Multiple Notifications With Different Labels
    When Query All Notifications By Specified Label With Limit
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct With Limit
    And Only Notifications With The Specified Label Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

# /notification/status/{status}
NotificationGET007 - Query notifications with specified status
    Given Create Multiple Notifications With Different Statuses
    When Query All Notifications By Specified Status
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct
    And Only Notifications With The Specified Status Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

NotificationGET008 - Query notifications with specified status by offset
    Given Create Multiple Notifications With Different Statuses
    When Query All Notifications By Specified Status With offset
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct With Offset
    And Only Notifications With The Specified Status Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

NotificationGET009 - Query notifications with specified status by limit
    Given Create Multiple Notifications With Different Statuses
    When Query All Notifications By Specified Status With Limit
    Then Should Return Status Code "200" And notifications
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Notifications Count Should Be Correct With Limit
    And Only Notifications With The Specified Status Should Be Listed
    [Teardown]  Delete Multiple Notifications By Ids

