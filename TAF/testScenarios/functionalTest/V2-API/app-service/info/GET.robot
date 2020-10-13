*** Settings ***
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Suite Setup      Setup Suite for App Service  ${AppServiceUrl_blackbox}
Suite Teardown   Suite Teardown for App Service
Default Tags     v2-api

*** Variables ***
${SUITE}          App-Service GET Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-get.log
${edgex_profile}  blackbox-tests
${AppServiceUrl_blackbox}  http://${BASE_URL}:48095
${api_version}  v2

*** Test Cases ***
InfoGET001 - Query ping
    When Query Ping
    Then Should Return Status Code "200" And timestamp
    And apiVersion Should be ${api_version}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

InfoGET002 - Query version
    When Query Version
    Then Should Return Status Code "200" And version
    And Should Return SDK Version
    And apiVersion Should be ${api_version}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

InfoGET003 - Query metrics
    When Query Metrics
    Then Should Return Status Code "200" And metrics
    And apiVersion Should be ${api_version}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

InfoGET004 - Query config
    When Query Config
    Then Should Return Status Code "200" And config
    And apiVersion Should be ${api_version}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

**** Keywords ***
Should Return SDK Version
    Should contain "sdk_version"

