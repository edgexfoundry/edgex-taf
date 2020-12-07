*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Info GET Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-info.log
${url}            ${coreDataUrl}
${api_version}    v2

*** Test Cases ***
InfoGET001 - Query ping
    When Query Ping
    Then Should Return Status Code "200" And timestamp
    And apiVersion Should be ${api_version}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

InfoGET002 - Query version
    When Query Version
    Then Should Return Status Code "200" And version
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

Test
    When Query Ping
    Then Should Return Status Code "200" And timestamp
    And apiVersion Should be ${api_version}
    And Response Time Should Be Less Than "100"ms