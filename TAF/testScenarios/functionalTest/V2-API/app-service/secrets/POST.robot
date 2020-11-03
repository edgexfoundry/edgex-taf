*** Settings ***
Library   Process
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Suite Setup      Setup Suite for App Service Secrets
Suite Teardown   Suite Teardown for App Service
Force Tags       v2-api

*** Variables ***
${SUITE}          App-Service Secrets POST Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-secrets.log
${api_version}  v2

*** Test Cases ***
SecretsPOST001 - Stores secrets to the secret client with Path
    [Tags]  SmokeTest
    When Store Secret Data With Path
    Then Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'
         ...  Run keywords  Should Return Status Code "201"
         ...  AND  Secrets Should be Stored
         ...  ELSE  Should Return Status Code "500"
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

ErrSecretsPOST004 - Stores secrets to the secret client fails (security not enabled)
    When Store Secret Data With Path
    Then Run Keyword if  $SECURITY_SERVICE_NEEDED == 'false'
         ...   Should Return Status Code "500"
         ...   ELSE  Should Return Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Setup Suite for App Service Secrets
    Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Run Keywords
    #EDGEX_SECURITY_SECRET_STORE: "true"
    ...             Set Suite Variable  ${edgex_profile}  http-export-secrets
    ...             AND  Setup Suite for App Service  http://${BASE_URL}:48098
    #EDGEX_SECURITY_SECRET_STORE: "false"
    ...             ELSE  Run keywords  Set Suite Variable  ${edgex_profile}  http-export
    ...             AND  Setup Suite for App Service  http://${BASE_URL}:48096

Get AppService Token
    ${command}=  Set Variable  docker exec app-service-${edgex_profile} cat /tmp/edgex/secrets/appservice-${edgex_profile}/secrets-token.json
    ${result} =  Run Process  ${command}  shell=yes  output_encoding=UTF-8
    ${result_string}=  Evaluate  json.loads('''${result.stdout}''')  json
    Set Test Variable  ${token}  ${result_string}[auth][client_token]

Secrets Should be Stored
    Get AppService Token
    Create Session  GetSecrets  url=https://${BASE_URL}:8200  disable_warnings=true
    ${headers}=  Create Dictionary  X-Vault-Token  ${token}
    ${resp}=  Get request  GetSecrets  /v1/secret/edgex/appservice-${edgex_profile}/${secrets_path}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}
    Should Contain  ${content}[data]  ${secrets_key}  ${secrets_value}


