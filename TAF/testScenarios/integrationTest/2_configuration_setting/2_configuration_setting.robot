*** Settings ***
Documentation    Service Operation Test Case
Library          RequestsLibrary
Library	         Collections
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Library          TAF/testCaseModules/keywords/setup/startup_checker.py
Library          TAF/testCaseModules/keywords/setup/edgex.py
Resource         TAF/testCaseModules/keywords/loggingAPI.robot
Suite Setup      Setup Suite
Suite Teardown   Suite Teardown
Default Tags  skipped

*** Variables ***
${SUITE}                service_operation
${WORK_DIR}             ${WORK_DIR}
${LOG_FILE_PATH}        ${WORK_DIR}/TAF/testArtifacts/logs/service_operation.log
${DEVICE_SERVICE_URL}   http://localhost:${SERVICE_PORT}
${LOGGING_SERVICE_URL}   http://localhost:${SUPPORT_LOGGING_PORT}
${METADATA_SERVICE_URL}   http://localhost:${CORE_METADATA_PORT}
${REGISTRY_URL}
${CONF_FIR}
${DS_PROFILE}
${REST_RES}

*** Keywords ***
# Setup called once before all test cases.
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Suite Setup

#TC0001
Bootstrap option "--registry" is set to "${registry_url}"
    Set Test Variable  ${REGISTRY_URL}  ${registry_url}

DS initialize with the registry url
    Modify consul config  /v1/kv/edgex/devices/1.0/${SERVICE_NAME}/Writable/LogLevel  DEBUG
    Remove services  ${SERVICE_NAME}
    Deploy device service with registry url   ${SERVICE_NAME}   ${REGISTRY_URL}

DS configuration settings should be provided by the registry
    Create Session   Device Service   url=${DEVICE_SERVICE_URL}
    ${resp}=   GET On Session   Device Service    /api/v1/config  expected_status=any
    Should contain      ${resp.json()["Writable"]["LogLevel"]}  DEBUG

#TC0002
DS configuration settings should be provided by the local configuration file
    Create Session   Device Service   url=${DEVICE_SERVICE_URL}
    ${resp}=   GET On Session   Device Service    /api/v1/config  expected_status=any
    Should contain      ${resp.json()["Writable"]["LogLevel"]}  INFO

#TC003
Bootstrap option "--confdir" is set to "${confdir_path}"
    Set Test Variable  ${CONF_FIR}  ${confdir_path}

DS initialize with the confdir option
    Remove services  ${SERVICE_NAME}
    Deploy device service with the confdir option   ${SERVICE_NAME}   ${CONF_FIR}

DS configuration settings should be provided by confdir
    Create Session   Device Service   url=${DEVICE_SERVICE_URL}
    ${resp}=   GET On Session   Device Service    /api/v1/config  expected_status=any
    Should contain      ${resp.json()["Device"]["ProfilesDir"]}  ${CONF_FIR}

#TC004
Bootstrap option "--profile" is set to "${config_profile_name}"
    Set Test Variable  ${CONF_FIR}  /custom-config
    Set Test Variable  ${DS_PROFILE}  ${config_profile_name}

DS initialize with the profile option
    Remove services  ${SERVICE_NAME}
    Deploy device service with the profile option   ${SERVICE_NAME}   ${DS_PROFILE}

#TC005
LogLevel Configuration changes on registry
    Remove device service logs
    Modify consul config  /v1/kv/edgex/devices/1.0/${SERVICE_NAME}/Writable/LogLevel  TRACE
    sleep  3

DS dynamically apply the logLevel changed settings
    Create Session   Logging Service   url=${LOGGING_SERVICE_URL}
    ${resp}=  GET On Session   Logging Service    /api/v1/logs/originServices/${SERVICE_NAME}/0/0/100
    ...       expected_status=any
    ${result} =  convert to string   ${resp.content}
    Should contain      ${result}  "Writeable configuration has been updated. Setting log level to TRACE"

Corresponding logLevel setting should be updated by DS
    Create Session   Device Service   url=${DEVICE_SERVICE_URL}
    ${resp}=   GET On Session   Device Service    /api/v1/config  expected_status=any
    Should contain      ${resp.json()["Writable"]["LogLevel"]}  TRACE

#TC006
Service ConnectRetries Configuration changes
    Modify consul config  /v1/kv/edgex/devices/1.0/${SERVICE_NAME}/Service/ConnectRetries  10
    sleep  3

Restart DS because DS cannot dynamically apply changed settings
    Restart services  ${SERVICE_NAME}

Corresponding Service ConnectRetries setting should be updated by DS
    Create Session   Device Service   url=${DEVICE_SERVICE_URL}
    ${resp}=   GET On Session   Device Service    /api/v1/config  expected_status=any
    ${result} =  convert to string   ${resp.json()["Service"]["ConnectRetries"]}
    Should contain      ${result}  10

*** Test Cases ***
ConfigurationSetting_TC0001 - Bootstrap option "--registry" is set
    Given Bootstrap option "--registry" is set to "consul://edgex-core-consul:8500"
    When DS initialize with the registry url
    Then DS configuration settings should be provided by the registry

ConfigurationSetting_TC0002 - Bootstrap option "--registry" is unset
    Given Bootstrap option "--registry" is set to ""
    When DS initialize with the registry url
    Then DS configuration settings should be provided by the local configuration file

ConfigurationSetting_TC0003 - Bootstrap option "--confdir" is set
    Given Bootstrap option "--confdir" is set to "/custom-config"
    When DS initialize with the confdir option
    Then DS configuration settings should be provided by confdir

ConfigurationSetting_TC0004 - Bootstrap option "--profile" is set
    Given Bootstrap option "--profile" is set to "docker"
    When DS initialize with the profile option
    Then DS configuration settings should be provided by confdir

ConfigurationSetting_TC0005 - Monitoring settings changes
    Given logLevel Configuration changes on registry
    When DS dynamically apply the logLevel changed settings
    Then Corresponding logLevel setting should be updated by DS

ConfigurationSetting_TC0006 - Startup settings changes
    Given Service ConnectRetries Configuration changes
    When Restart DS because DS cannot dynamically apply changed settings
    Then Corresponding Service ConnectRetries setting should be updated by DS
