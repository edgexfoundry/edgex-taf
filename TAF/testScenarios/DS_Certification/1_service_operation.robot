*** Settings ***
Documentation   Service Operation Test Case
Library          REST
Library          TAF.utils.src.setup.setup_teardown
Library          TAF.utils.src.setup.edgex
Library          TAF.utils.src.setup.consul
Suite Setup      Setup Suite
Suite Teardown   Suite Teardown

*** Variables ***
${SUITE}              service_operation
${LOG_FILE_PATH}           ${WORK_DIR}/TAF/testArtifacts/logs/service_operation.log

*** Keywords ***
# Setup called once before all test cases.
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Demo Suite Setup

Shutdown "${service_name}" service and Modify Configuration Service.ConnectRetries = 1 and Restart DS
    Stop services  ${service_name}
    Modify consul config  /v1/kv/edgex/devices/1.0/${DEVICE_SERVICE_NAME}/${DEVICE_SERVICE_NAME}/Service/ConnectRetries  1
    Restart services  ${DEVICE_SERVICE_NAME}

Restart EdgeX
    Deploy services  data  metadata  command  ${DEVICE_SERVICE_NAME}

Send GET request "${path_version}" to "${host_ds}"
    ${res} =  GET  ${host_ds}${path_version}        headers={ "Accept": "text/plain" }
    Set Test Variable  ${REST_RES}  ${res}

Status code in "${response}" should be "${status_code}"
    ${expect} =  Convert to Integer  ${status_code}
    Should Be Equal    ${response['status']}   ${expect}

Validate ${response} contains version element "${version_number}"
    Should Be Equal    ${response['body']}   ${version_number}

Validate "${response}" contains DS configuration
    Should Be True     'Writable' in ${response['body']}
    Should Be True     'Service' in ${response['body']}
    Should Be True     'Registry' in ${response['body']}
    Should Be True     'Clients' in ${response['body']}
    Should Be True     'Device' in ${response['body']}
    Should Be True     'Logging' in ${response['body']}

Validate "${response}" contains DS metrics
    Should Be True     'Alloc' in ${response['body']}
    Should Be True     'TotalAlloc' in ${response['body']}
    Should Be True     'Sys' in ${response['body']}
    Should Be True     'Mallocs' in ${response['body']}
    Should Be True     'Frees' in ${response['body']}
    Should Be True     'LiveObjects' in ${response['body']}

*** Test Cases ***
ServiceOperation_TC0001a - Startup failed (Core Metadata Service is unavailable)
    [Tags]  Skipped
    [Setup]  Shutdown "metadata" service and Modify Configuration Service.ConnectRetries = 1 and Restart DS
    Given "Core Metadata" service is unavailable
    When DS try to startup
    Then DS should log an error after timeout
    And DS should exit
    [Teardown]  Restart EdgeX


ServiceOperation_TC0001b - Startup failed (Core Data Service is unavailable)
    [Tags]  Skipped
    [Setup]  Shutdown "Core Data" service and Modify Configuration Service.ConnectRetries = 1 and Restart DS
    Given "Core Data" service is unavailable
    When DS try to startup
    Then DS should log an error after timeout
    And DS should exit
    [Teardown]  Restart EdgeX

ServiceOperation_TC0002 - Startup (DeviceService instance is not found)
    [Tags]  Skipped
    Given "${new_service_name}" instance is not found in Core Metadata
    When DS finishes with initialization
    Then DS should create a new "${new_service_name}" instance in Core Metadata

ServiceOperation_TC0003 - Startup (DeviceService instance is found)
    [Tags]  Skipped
    Given "${service_name}" instance is found in Core Metadata
    When DS finishes with initialization
    Then DS should load the "${service_name}" instance from Core Metadata

ServiceOperation_TC0004 - Register as a service
    [Tags]  Skipped
    Given DS is configured to use the registry "${registry_url}"
    When DS finishes with initialization
    Then DS should register as a service "${service_name}" to the registry "${registry_url}"

ServiceOperation_TC0005 - Register as a service failed
    [Tags]  Skipped
    Given DS is configured to use the registry "${invalid_registry_url}"
    When DS finishes with initialization
    Then DS should log an error
    And DS should exit

ServiceOperation_TC0006 - Version identification
    When Send GET request "/api/version" to "http://localhost:49990"
    Then Status code in "${REST_RES}" should be "200"
    And Validate ${REST_RES} contains version element "1.0.0"

ServiceOperation_TC0007 - Health check
    # In Geneva and subsequent releases the response will be the string "pong"
    When Send GET request "/api/v1/ping" to "http://localhost:49990"
    Then Status code in "${REST_RES}" should be "200"
    And Validate ${REST_RES} contains version element "1.0.0"

ServiceOperation_TC0008 - Configuration check
    When Send GET request "/api/v1/config" to "http://localhost:49990"
    Then Validate "${REST_RES}" contains DS configuration

ServiceOperation_TC0009 - Metrics
    When Send GET request "/api/v1/metrics" to "http://localhost:49990"
    Then Validate "${REST_RES}" contains DS metrics

