*** Settings ***
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup      Run Keywords  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
                 ...      AND  Setup Suite
Suite Teardown   Run Teardown Keywords

*** Variables ***
${SUITE}          Support-Notifications Secrets POST Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-secrets.log
${url}            ${URI_SCHEME}://${BASE_URL}:${SUPPORT_NOTIFICATIONS_PORT}

*** Test Cases ***
SecretsPOST001 - Stores secrets to the secret client with Path
    When Store Secret Data With Path
    Then Should Return Status Code "201"
    And Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Service support-notifications Secrets Should be Stored
        ...       ELSE  Secrets Should be Stored To Consul  support-notifications
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSecretsPOST001 - Stores secrets to the secret client fails (empty path)
    When Store Secret Data With Empty Path
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSecretsPOST002 - Stores secrets to the secret client fails (missing key)
    When Store Secret Data With Missing Key
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSecretsPOST003 - Stores secrets to the secret client fails (missing value)
    When Store Secret Data With Missing Value
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
