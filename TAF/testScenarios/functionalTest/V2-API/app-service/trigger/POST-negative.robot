*** Settings ***
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Library   TAF/testCaseModules/keywords/consul/consul.py
Suite Setup  Setup Suite for App Service  ${AppServiceUrl_functional}
Suite Teardown   Suite Teardown for App Service
Force Tags       v2-api

*** Variables ***
${SUITE}          App-Service Trigger POST Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-trigger-negative.log
${AppServiceUrl_functional}  http://${BASE_URL}:48105

*** Test Cases ***
ErrTriggerPOST001 - Trigger pipeline fails (Invalid Data)
    Given Set Functions FilterByDeviceName, Transform, SetResponseData
    When Trigger Function Pipeline With Invalid Data
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTriggerPOST002 - Trigger pipeline fails (Unprocessable Entity)
    Given Set Functions FilterByDeviceName, Transform, SetResponseData
    And Accept raw data  true
    When Trigger Function Pipeline With Invalid Data
    Then Should Return Status Code "422"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Accept raw data  false

*** Keywords ***
Accept raw data
    [arguments]  ${bool}
    ${path}=  Set variable  /v1/kv/edgex/appservices/${CONSUL_CONFIG_VERSION}/app-functional-tests/Writable/Pipeline/UseTargetTypeOfByteArray
    Modify consul config  ${path}  ${bool}
    sleep  1

