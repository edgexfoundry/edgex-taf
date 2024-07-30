*** Settings ***
Library      Collections
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-keeper/coreKeeperAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Keeper Registry POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-registry-post.log

*** Test Cases ***
RegistryPOST001 - Register a service
    Given Set Test Variable  ${serviceId}  testRegistryPostService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    When Register A New Service  ${Registry}
    Then Should Return Status Code "201"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryPOST001 - Register a service with existed name
    Given Set Test Variable  ${serviceId}  testRegistryPostService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    When Register A New Service  ${Registry}
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryPOST002 - Should return error when registering service without serviceId
    Given Generate Registry Data  ${EMPTY}  test-service-host  ${12345}
    When Register A New Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST003 - Should return error when registering service without host
    Given Generate Registry Data  testRegistryPostService  ${EMPTY}  ${12345}
    When Register A New Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST004 - Should return error when registering service without port
    Given Generate Registry Data  testRegistryPostService  test-service-host  ${EMPTY}
    When Register A New Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST005 - Should return error when registering service without healthCheck
    Given Generate Registry Data  testRegistryPostService  test-service-host  ${12345}
    And Remove From Dictionary  ${Registry}[registration]  healthCheck
    When Register A New Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST006 - Should return error when registering service without healthCheck interval
    Given Generate Registry Data  testRegistryPostService  test-service-host  ${12345}
    And Remove From Dictionary  ${Registry}[registration][healthCheck]  interval
    When Register A New Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST007 - Should return error when registering service without healthCheck path
    Given Generate Registry Data  testRegistryPostService  test-service-host  ${12345}
    And Remove From Dictionary  ${Registry}[registration][healthCheck]  path
    When Register A New Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPOST008 - Should return error when registering service without healthCheck type
    Given Generate Registry Data  testRegistryPostService  test-service-host  ${12345}
    And Remove From Dictionary  ${Registry}[registration][healthCheck]  type
    When Register A New Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
