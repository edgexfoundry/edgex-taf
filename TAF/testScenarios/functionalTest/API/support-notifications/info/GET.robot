*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Notifications Info GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notification-info.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
InfoGET001 - Query ping
    When Query Ping
    Then Should Return Status Code "200" And timestamp
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

InfoGET002 - Query version
    When Query Version
    Then Should Return Status Code "200" And version
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

InfoGET003 - Query config
    When Query Config
    Then Should Return Status Code "200" And config
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

