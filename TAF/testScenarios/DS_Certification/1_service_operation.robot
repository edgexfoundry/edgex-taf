*** Settings ***
Documentation    Service Operation Test Case
Library          RequestsLibrary
Library	         Collections
Library          TAF.utils.src.setup.setup_teardown
Library          TAF.utils.src.setup.startup_checker
Library          TAF.utils.src.setup.edgex
Library          TAF.utils.src.setup.consul
Resource         ./keywords/commonKeywords.robot
Suite Setup      Setup Suite
Suite Teardown   Suite Teardown

*** Variables ***
${SUITE}                service_operation
${WORK_DIR}             ${WORK_DIR}
${LOG_FILE_PATH}        ${WORK_DIR}/TAF/testArtifacts/logs/service_operation.log
${DEVICE_SERVICE_URL}   http://localhost:${DEVICE_SERVICE_PORT}
${LOGGING_SERVICE_URL}   http://localhost:${SUPPORT_LOGGING_PORT}
${METADATA_SERVICE_URL}   http://localhost:${CORE_METADATA_PORT}
${REGISTRY_URL}   http://localhost:${REGISTRY_PORT}
${REST_RES}

*** Keywords ***
# Setup called once before all test cases.
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Demo Suite Setup

Restart EdgeX
    Deploy services  data  metadata  command  ${DEVICE_SERVICE_NAME}

Send GET request "${request_path}" to "${url}"
    Create Session   Edgex Service   url=${url}
    ${resp}=   get request   Edgex Service    ${request_path}
    Set Test Variable  ${REST_RES}  ${resp}

Status code "${status_code}" should be "${expect}"
    ${result} =  convert to string   ${status_code}
    Should Be Equal    ${result}   ${expect}

DS should log "${msg}"
    Send GET request "/api/v1/logs/originServices/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}/0/0/100" to "${LOGGING_SERVICE_URL}"
    ${result} =  convert to string   ${REST_RES.content}
    Should contain      ${result}  ${msg}

#TC0001a, TC0001b
"${service_name}" service is unavailable
    Stop services  ${service_name}

DS try to startup
    Modify consul config  /v1/kv/edgex/devices/1.0/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}/Service/ConnectRetries  1
    Restart services  ${DEVICE_SERVICE_NAME}
    Sleep	20
    Modify consul config  /v1/kv/edgex/devices/1.0/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}/Service/ConnectRetries  3

DS should log "${error_msg}" after timeout
    Send GET request "/api/v1/logs/originServices/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}/0/0/100" to "${LOGGING_SERVICE_URL}"
    ${result} =  convert to string   ${REST_RES.content}
    Should contain      ${result}  ${error_msg}

DS should exit
    ${result} =  Check service is available   ${DEVICE_SERVICE_PORT}  "/api/v1/ping"
    should not be true    ${result}

#TC0002
DS instance is not found in Core Metadata
    Stop services  ${DEVICE_SERVICE_NAME}
    Delete device service instance

DS finishes with initialization
    Deploy services  ${DEVICE_SERVICE_NAME}

Delete device service instance
    Create Session   Core Metadata   url=${METADATA_SERVICE_URL}
    ${resp}=   Delete Request   Core Metadata    /api/v1/deviceservice/name/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}
    Should Be Equal As Strings  ${resp.status_code}  200
    log  ${resp.content}

DS should create a new DS instance in Core Metadata
    Create Session   Core Metadata   url=${METADATA_SERVICE_URL}
    ${resp}=   Get Request   Core Metadata    /api/v1/deviceservice/name/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}
    ${result} =  convert to string   ${resp.content}
    Should contain      ${result}  ${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}

#TC003
DS instance is found in Core Metadata
    DS should create a new DS instance in Core Metadata
    Remove services  ${DEVICE_SERVICE_NAME}

DS should load the DS instance from Core Metadata
    DS should log "Device Service ${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]} exists"

#TC004
DS is configured to use the registry
    Create Session   Device Service   url=${DEVICE_SERVICE_URL}
    ${resp}=   Get Request   Device Service    /api/v1/config
    Should contain      ${resp.json()["Registry"]["Host"]}  edgex-core-consul

DS should register as a service to the registry
    Create Session   Registry   url=${REGISTRY_URL}
    ${resp}=   Get Request   Registry    /v1/health/checks/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}
    Should contain      ${resp.json()[0]["Status"]}  passing
    Remove services  ${DEVICE_SERVICE_NAME}

#TC005
DS is configured to use the invalid registry url and initialization
    Remove services  ${DEVICE_SERVICE_NAME}
    Deploy device service with registry url   ${DEVICE_SERVICE_NAME}   consul://invalid_url:1234

#TC0006
Validate ${content} contains version element "${expect}"
    ${result} =  convert to string   ${content}
    Should Be Equal    ${result}   ${expect}

#TC0008
Validate "${content}" contains DS configuration
    ${result} =  convert to string   ${content}
    Should contain      ${result}  "Writable"
    Should contain      ${result}  "Service"
    Should contain      ${result}  "Registry"
    Should contain      ${result}  "Clients"
    Should contain      ${result}  "Device"
    Should contain      ${result}  "Logging"

#TC0009
Validate "${content}" contains DS metrics
    ${result} =  convert to string   ${content}
    Should contain     ${result}  "Alloc"
    Should contain     ${result}  "TotalAlloc"
    Should contain     ${result}  "Sys"
    Should contain     ${result}  "Mallocs"
    Should contain     ${result}  "Frees"
    Should contain     ${result}  "LiveObjects"

#TC0010
Start EdgeX with Registry DS to consul
    Remove services  ${DEVICE_SERVICE_NAME}
    Deploy device service with registry url   ${DEVICE_SERVICE_NAME}   consul://edgex-core-consul:8500
    sleep  3
    DS should register as a service to the registry
    sleep  3

Shutdown DS
    Remove services  ${DEVICE_SERVICE_NAME}
    sleep  3

DS should be unregistered to consul
    Create Session   Registry   url=${REGISTRY_URL}
    ${resp}=   Get Request   Registry    /v1/health/checks/${SERVICE_NAME_MAPPING["${DEVICE_SERVICE_NAME}"]}
    Should contain      ${resp.json()[0]["Status"]}  critical
    Remove services  ${DEVICE_SERVICE_NAME}

*** Test Cases ***
ServiceOperation_TC0001a - Startup failed (Core Metadata Service is unavailable)
    Given "metadata" service is unavailable
    When DS try to startup
    Then DS should log "service dependency Metadata checking time out" after timeout
    And DS should exit
    [Teardown]  Restart EdgeX

ServiceOperation_TC0001b - Startup failed (Core Data Service is unavailable)
    Given "data" service is unavailable
    When DS try to startup
    Then DS should log "service dependency Data checking time out" after timeout
    And DS should exit
    [Teardown]  Restart EdgeX

ServiceOperation_TC0002 - Startup (DeviceService instance is not found)
    Given DS instance is not found in Core Metadata
    When DS finishes with initialization
    Then DS should create a new DS instance in Core Metadata

ServiceOperation_TC0003 - Startup (DeviceService instance is found)
    Given DS instance is found in Core Metadata
    When DS finishes with initialization
    Then DS should load the DS instance from Core Metadata

ServiceOperation_TC0004 - Register as a service
    Given DS is configured to use the registry
    When DS finishes with initialization
    Then DS should register as a service to the registry

ServiceOperation_TC0005 - Register as a service failed
    When DS is configured to use the invalid registry url and initialization
    Then DS should exit
    [Teardown]  Restart EdgeX

ServiceOperation_TC0006 - Version identification
    When Send GET request "/api/version" to "${DEVICE_SERVICE_URL}"
    Then Status code "${REST_RES}" should be "200"
    And Validate ${REST_RES.content} contains version element "1.0.0"

ServiceOperation_TC0007 - Health check
    # In Geneva and subsequent releases the response will be the string "pong"
    When Send GET request "/api/v1/ping" to "${DEVICE_SERVICE_URL}"
    Then Status code "${REST_RES.status_code}" should be "200"
    And Validate ${REST_RES.content} contains version element "1.0.0"

ServiceOperation_TC0008 - Configuration check
    When Send GET request "/api/v1/config" to "${DEVICE_SERVICE_URL}"
    Then Validate "${REST_RES.content}" contains DS configuration

ServiceOperation_TC0009 - Metrics
    When Send GET request "/api/v1/metrics" to "${DEVICE_SERVICE_URL}"
    Then Validate "${REST_RES.content}" contains DS metrics

ServiceOperation_TC0010 - Unregistered to registry
    Given Start EdgeX with Registry DS to consul
    When Shutdown DS
    Then DS should be unregistered to consul
