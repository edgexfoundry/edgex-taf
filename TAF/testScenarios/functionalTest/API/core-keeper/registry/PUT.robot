*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-keeper/coreKeeperAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Keeper Registry PUT Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-registry-put.log

*** Test Cases ***
RegistryPUT001 - Update interval for registered service
    Given Set Test Variable  ${serviceId}  testRegistryPutService
    And Set Test Variable  ${updateValue}  20s
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    And Set To Dictionary  ${Registry}[registration][healthCheck]  Interval=${updateValue}
    When Update Registered Service  ${Registry}
    Then Should Return Status Code "204"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Interval Should Be Updated
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryPUT001 - Update interval for unregistered service
    Given Set Test Variable  ${serviceId}  testRegistryPutService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    When Update Registered Service  ${Registry}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPUT002 - Should return error when registering service without host
    Given Set Test Variable  ${serviceId}  testRegistryPutService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    And Set To Dictionary  ${Registry}[registration]  host=${EMPTY}
    When Update Registered Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryPUT003 - Should return error when registering service without port
    Given Set Test Variable  ${serviceId}  testRegistryPutService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    And Set To Dictionary  ${Registry}[registration]  port=${EMPTY}
    When Update Registered Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryPUT004 - Should return error when registering service without healthCheck
    Given Set Test Variable  ${serviceId}  testRegistryPutService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    And Set To Dictionary  ${Registry}[registration]  healthCheck=${EMPTY}
    When Update Registered Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryPUT005 - Should return error when registering service without healthCheck interval
    Given Set Test Variable  ${serviceId}  testRegistryPutService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    And Set To Dictionary  ${Registry}[registration][healthCheck]  Interval=${EMPTY}
    When Update Registered Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryPUT006 - Should return error when registering service without healthCheck path
    Given Set Test Variable  ${serviceId}  testRegistryPutService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    And Set To Dictionary  ${Registry}[registration][healthCheck]  path=${EMPTY}
    When Update Registered Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryPUT007 - Should return error when registering service without healthCheck type
    Given Set Test Variable  ${serviceId}  testRegistryPutService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    And Set To Dictionary  ${Registry}[registration][healthCheck]  type=${EMPTY}
    When Update Registered Service  ${Registry}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Deregister Service  ${serviceId}

*** Keywords ***
Interval Should Be Updated
    Query Registered Service By ServiceId  ${serviceId}
    Should Be Equal As Strings  ${content}[registration][HealthCheck][interval]  ${updateValue}
