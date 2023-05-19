*** Settings ***
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Suite Setup      Setup Suite for App Service Secrets
Suite Teardown   Suite Teardown for App Service

*** Variables ***
${SUITE}          App-Service Secrets POST Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-secrets.log

*** Test Cases ***
SecretsPOST001 - Stores secrets to the secret client with Path
    When Store Secret Data With Path
    Then Should Return Status Code "201"
    And Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Service ${app_service_name} Secrets Should be Stored
        ...       ELSE  Secrets Should be Stored To Consul  ${app_service_name}
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

*** Keywords ***
Setup Suite for App Service Secrets
    Set Suite Variable  ${app_service_name}  app-http-export
    Setup Suite for App Service  http://${BASE_URL}:${APP_HTTP_EXPORT_PORT}
