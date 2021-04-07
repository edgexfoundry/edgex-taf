*** Settings ***
Resource   TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource   TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Variables  TAF/testData/app-service/trigger_response_content.py
Suite Setup      Setup Suite for App Service  ${AppServiceUrl_functional}
Suite Teardown   Suite Teardown for App Service
Force Tags       v2-api

*** Variables ***
${SUITE}          App-Service Trigger POST Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-trigger-positive.log
${AppServiceUrl_functional}  http://${BASE_URL}:48105

*** Test Cases ***
TriggerPOST001 - Trigger pipeline (no match)
    Given Set Functions FilterByDeviceName, Transform, SetResponseData
    When Trigger Function Pipeline With No Matching DeviceName
    Then Should Return Status Code "200"
    And Body Should Match Empty
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST002 - Trigger pipeline (XML)
    [Tags]  SmokeTest
    Given Set Functions FilterByDeviceName, Transform, SetResponseData
    And Set Transform Type xml
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/xml"
    And Body Should Match XML String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST003 - Trigger pipeline (JSON)
    Given Set Functions FilterByDeviceName, Transform, SetResponseData
    And Set Transform Type json
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Body Should Match JSON String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST004 - Trigger pipeline (JSON-GZIP)
    Given Set Functions FilterByDeviceName, Transform, Compress, SetResponseData
    And Set Transform Type json
    And Set Compress Algorithm gzip
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Body Should Match JSON-GZIP String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST005 - Trigger pipeline (JSON-ZLIB)
    Given Set Functions FilterByDeviceName, Transform, Compress, SetResponseData
    And Set Transform Type json
    And Set Compress Algorithm zlib
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Should Return Content-Type "text/plain"
    And Body Should Match JSON-ZLIB String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

TriggerPOST006 - Trigger pipeline (JSON-ZLIB-AES)
    Given Set Functions FilterByDeviceName, Transform, Compress, Encrypt, SetResponseData
    And Set Transform Type json
    And Set Compress Algorithm zlib
    And Set Encrypt Algorithm aes
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And Should Return Content-Type "text/plain"
    And Body Should Match JSON-ZLIB-AES String
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Body Should Match ${type}
    ${length}=  Get Length  ${content}
    ${json_string}=  Evaluate  json.loads('''${trigger_content["JSON String"]}''')
    Run keyword if  '${type}' == 'Empty'  Should be true  ${length}==0
    ...    ELSE IF  '${type}' == 'JSON String'  Should be true  "${content}" == "${json_string}"
    ...    ELSE     Should be true  '${content}' == '${trigger_content["${type}"]}'

