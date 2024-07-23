*** Settings ***
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Suite Setup  Setup Suite for App Service  ${AppServiceUrl_functional}
Suite Teardown   Suite Teardown for App Service

*** Variables ***
${SUITE}          App-Service Trigger POST Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-trigger-negative.log
${AppServiceUrl_functional}  http://${BASE_URL}:${APP_FUNCTIONAL_TESTS_PORT}
${APP_SERVICE_NAME}  app-functional-tests

*** Test Cases ***
ErrTriggerPOST001 - Trigger pipeline fails (Invalid Data)
    Given Set ${APP_SERVICE_NAME} Functions FilterByDeviceName, Transform, SetResponseData
    And Run Keyword If  "${REGISTRY_SERVICE}" == "Keeper"  Restart Services  ${APP_SERVICE_NAME}
    When Trigger Function Pipeline With Invalid Data
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTriggerPOST002 - Trigger pipeline fails (Unprocessable Entity)
    Given Set ${APP_SERVICE_NAME} Functions FilterByDeviceName, Transform, SetResponseData
    And Update Target Type To raw
    And Run Keyword If  "${REGISTRY_SERVICE}" == "Keeper"  Restart Services  ${APP_SERVICE_NAME}
    When Trigger Function Pipeline With Invalid Data
    Then Should Return Status Code "422"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Update Target Type To event

*** Keywords ***
Update Target Type To ${value}
    ${path}=  Set variable  /app-functional-tests/Writable/Pipeline/TargetType
    Update Configuration On Registry Service  ${path}  ${value}

