*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup      Run Keywords  Setup Suite  AND  Deploy App Service
Suite Teardown   Run Keywords  Suite Teardown  And  Remove App Service

*** Variables ***
${SUITE}          App-Service Secrets POST Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-secrets.log

*** Test Cases ***
SecretsPOST001 - Stores secrets to the secret client
    When Store Secret Data
    Then Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'
         ...  Should Return Status Code "201"
         ...  ELSE IF  Should Return Status Code "500"

SecretsPOST002 - Stores secrets to the secret client With Path
    When Store Secret Data With Path
    Then Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'
         ...  Should Return Status Code "201"
         ...  ELSE IF  Should Return Status Code "500"

ErrSecretsPOST001 - Stores secrets to the secret client fails (missing key)
    When Store Secret Data With Missing Key
    Then Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'
         ...  Should Return Status Code "400"
         ...  ELSE IF  Should Return Status Code "500"

ErrSecretsPOST002 - Stores secrets to the secret client fails (missing value)
    When Store Secret Data With Missing Value
    Then Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'
         ...  Should Return Status Code "400"
         ...  ELSE IF  Should Return Status Code "500"
