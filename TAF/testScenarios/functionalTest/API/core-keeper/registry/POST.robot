*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Core Keeper Registry POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-registry-post.log

*** Test Cases ***
RegistryPOST001 - Register a service
    When Register A Service
    Then Should Return Status Code "201"
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Service Should Be Registered
    [Teardown]  Delete Registered Service

ErrRegistryPOST001 - Register a service with existed name
    Given Register A Service
    When Register An Exited Service
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Registered Service

ErrRegistryPOST002 - Should return error when registering service without serviceId
    When Register A Service Without serviceId Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST003 - Should return error when registering service without host
    When Register A Service Without Host Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST004 - Should return error when registering service without port
    When Register A Service Without Port Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST005 - Should return error when registering service without healthCheck
    When Register A Service Without healthCheck Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST006 - Should return error when registering service without healthCheck interval
    When Register A Service Without healthCheck Interval Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST007 - Should return error when registering service without healthCheck path
    When Register A Service Without healthCheck Path Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST008 - Should return error when registering service without healthCheck type
    When Register A Service Without healthCheck Type Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
