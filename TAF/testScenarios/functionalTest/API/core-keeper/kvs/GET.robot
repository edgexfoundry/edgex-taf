*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Core Keeper Key/Value GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-kvs-get.log

*** Test Cases ***
KVsGET001 - Value should be returned when query by configuration name(key)
    When Query Configuration By Key
    Then Should Return Status Code "200" And response
    And Configuration Value Should Be Correct
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

KVsGET002 - Only service configurations are listed if query by service level
    When Query Configuration By Service Level
    Then Should Return Status Code "200" And response
    And Only Service Configurations Are Listed
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrKVsGET001 - Should return error when query by invalid configuration name(key)
    When Query Configuration By Invalid Key
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
