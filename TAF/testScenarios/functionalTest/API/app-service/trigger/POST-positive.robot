*** Settings ***
Resource   TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource   TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Variables  TAF/testData/app-service/trigger_response_content.py
Suite Setup      Setup Suite for App Service  ${AppServiceUrl_functional}
Suite Teardown   Suite Teardown for App Service

*** Variables ***
${SUITE}          App-Service Trigger POST Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-trigger-positive.log
${AppServiceUrl_functional}  http://${BASE_URL}:${APP_FUNCTIOAL_TESTS_PORT}

*** Test Cases ***
TriggerPOST001 - Trigger pipeline (no match)
    Given Set app-functional-tests Functions FilterByDeviceName, Transform, SetResponseData
    When Trigger Function Pipeline With No Matching DeviceName
    Then Should Return Status Code "200"
    And Body Should Match Empty
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST002 - Trigger pipeline (XML)
    [Tags]  SmokeTest
    Given Set app-functional-tests Functions FilterByDeviceName, Transform, SetResponseData
    And Set Transform Type xml
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/xml"
    And Body Should Match XML String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST003 - Trigger pipeline (JSON)
    Given Set app-functional-tests Functions FilterByDeviceName, Transform, SetResponseData
    And Set Transform Type json
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Body Should Match JSON String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST004 - Trigger pipeline (JSON-GZIP)
    Given Set app-functional-tests Functions FilterByDeviceName, Transform, Compress, SetResponseData
    And Set Transform Type json
    And Set Compress Algorithm gzip
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Body Should Match JSON-GZIP String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST005 - Trigger pipeline (JSON-ZLIB)
    Given Set app-functional-tests Functions FilterByDeviceName, Transform, Compress, SetResponseData
    And Set Transform Type json
    And Set Compress Algorithm zlib
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Should Return Content-Type "text/plain"
    And Body Should Match JSON-ZLIB String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST006 - Trigger pipeline (AES26)
    [Setup]  Skip If  $SECURITY_SERVICE_NEEDED == 'false'
    Given Store Secret Data With AES256 Auth
    And Set app-functional-tests Functions FilterByDeviceName, Encrypt, SetResponseData
    And Set Encrypt Algorithm aes256
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Should Return Content-Type "text/plain"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And MAC and Decrypted Response both are Correct

*** Keywords ***
Body Should Match ${type}
    ${length}=  Get Length  ${content}
    ${json_string}=  Evaluate  json.loads('''${trigger_content["JSON String"]}''')
    Run keyword if  '${type}' == 'Empty'  Should be true  ${length}==0
    ...    ELSE IF  '${type}' == 'JSON String'  Should be true  "${content}" == "${json_string}"
    ...    ELSE     Should be true  '${content}' == '${trigger_content["${type}"]}'

MAC and Decrypted Response both are Correct
    ${result}  Run Process  python ${WORK_DIR}/TAF/utils/src/setup/aes256-decrypt.py ${secrets_value} ${content} &
    ...           shell=True  stderr=STDOUT
    Run Keyword If  '${result.stdout}' == 'Incorrect MAC'  Fail  MAC Value is Incorrect
    ...       ELSE  Decrypted Response Should be Correct  ${result.stdout}

Decrypted Response Should be Correct
    [Arguments]  ${result}
    ${result_json}  Evaluate  json.loads('''${result}''')
    ${request}  Evaluate  json.loads('''${trigger_content["JSON String"]}''')
    Should Be Equal As Strings  ${result_json}  ${request}
