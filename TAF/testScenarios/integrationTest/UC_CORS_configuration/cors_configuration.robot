*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords   Setup Suite
             ...      AND  Skip If  $SECURITY_SERVICE_NEEDED == 'true'
             ...      AND  Set Service.CORSConfiguration.EnableCORS to true For core-metadata On Consul
             ...      AND  Set Service.CORSConfiguration.CORSAllowCredentials to true For core-metadata On Consul
             ...      AND  Restart Services  core-metadata
Suite Teardown  Run Keywords  Set Service.CORSConfiguration.EnableCORS to false For core-metadata On Consul
                ...      AND  Restart Services  core-metadata
                ...      AND  Run Teardown Keywords
Force Tags      MessageBus=redis

*** Variables ***
${SUITE}  CORS Configuration
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/cors_configuration.log
${coreMetadataUrl}  ${URI_SCHEME}://${BASE_URL}:${CORE_METADATA_PORT}

*** Test Cases ***
CORS001-Enable CORS without Origin header
    ${header_keys}  Create List  Access-Control-Request-Method
    ${header_values}  Create List  GET
    ${unexpected_headers}  Create List  Access-Control-Expose-Headers  Access-Control-Allow-Origin
                         ...     Access-Control-Allow-Credentials  Vary
    When Send GET Request With Headers  ${header_keys}  ${header_values}
    Then Header Should Not Contain  ${unexpected_headers}

CORS002-Enable CORS and receive a prefligt request
    ${header_keys}  Create List  Access-Control-Request-Method  Origin
    ${header_values}  Create List  GET  http://localhost
    ${expected_headers}  Create List  Vary  Access-Control-Allow-Headers  Access-Control-Allow-Methods
                         ...   Access-Control-Allow-Origin  Access-Control-Allow-Credentials  Access-Control-Max-Age
    ${unexpected_headers}  Create List  Access-Control-Expose-Headers
    When Send OPTIONS Request With Headers  ${header_keys}  ${header_values}
    Then Header Should Contain  ${expected_headers}
    And Header Should Not Contain  ${unexpected_headers}

CORS003-Enable CORS and receive an actual request
    ${header_keys}  Create List  Access-Control-Request-Method  Origin
    ${header_values}  Create List  GET  http://localhost
    ${expected_headers}  Create List  Access-Control-Expose-Headers  Access-Control-Allow-Origin
                         ...     Access-Control-Allow-Credentials  Vary
    When Send GET Request With Headers  ${header_keys}  ${header_values}
    Then Header Should Contain  ${expected_headers}

CORS004-Enable CORS and receive a prefligt request with CORSAllowCredentials=false
    [Setup]  Run Keywords  Set Service.CORSConfiguration.CORSAllowCredentials to false For core-metadata On Consul
             ...      AND  Restart Services  core-metadata
    ${header_keys}  Create List  Access-Control-Request-Method  Origin
    ${header_values}  Create List  GET  http://localhost
    ${expected_headers}  Create List  Vary  Access-Control-Allow-Headers  Access-Control-Allow-Methods
                         ...   Access-Control-Allow-Origin  Access-Control-Max-Age
    ${unexpected_headers}  Create List  Access-Control-Expose-Headers
    When Send OPTIONS Request With Headers  ${header_keys}  ${header_values}
    Then Header Should Contain  ${expected_headers}
    And Header Should Not Contain  ${unexpected_headers}

CORS005-Enable CORS and receive an actual request with CORSAllowCredentials=false
    [Setup]  Run Keywords  Set Service.CORSConfiguration.CORSAllowCredentials to false For core-metadata On Consul
             ...      AND  Restart Services  core-metadata
    ${header_keys}  Create List  Access-Control-Request-Method  Origin
    ${header_values}  Create List  GET  http://localhost
    ${expected_headers}  Create List  Access-Control-Expose-Headers  Access-Control-Allow-Origin  Vary
    When Send GET Request With Headers  ${header_keys}  ${header_values}
    Then Header Should Contain  ${expected_headers}

CORS006-Not enable CORS
    [Setup]  Run Keywords  Set Service.CORSConfiguration.EnableCORS to false For core-metadata On Consul
             ...      AND  Restart Services  core-metadata
    ${unexpected_headers}  Create List  Access-Control-Expose-Headers  Access-Control-Allow-Origin
                         ...     Access-Control-Allow-Credentials  Vary
    When Send GET Request Without CORS Headers
    Then Header Should Not Contain  ${unexpected_headers}

*** Keywords ***
Set Service.CORSConfiguration.${config} to ${value} For ${service_name} On Consul
    ${path}=  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/${service_name}/Service/CORSConfiguration/${config}
    Update Service Configuration On Consul  ${path}  ${value}

Send ${method} Request With Headers
    [Arguments]  ${header_keys}  ${header_values}
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    FOR  ${key}  ${value}  IN ZIP  ${header_keys}  ${header_values}
        Set To Dictionary  ${headers}  ${key}=${value}
    END
    Create Session  Ping  url=${coreMetadataUrl}  disable_warnings=true
    ${resp}  Run Keyword If  "${method}" == "GET"  GET On Session  Ping  api/${API_VERSION}/ping  headers=${headers}  expected_status=200
             ...    ELSE IF  "${method}" == "OPTIONS"  OPTIONS On Session  Ping  api/${API_VERSION}/ping  headers=${headers}  expected_status=200
             ...       ELSE  Fail  Invalid Method: ${method}
    Set Test Variable  ${response_headers}  ${resp.headers}

Send GET Request Without CORS Headers
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    Create Session  Ping  url=${coreMetadataUrl}  disable_warnings=true
    ${resp}  GET On Session  Ping  api/${API_VERSION}/ping  headers=${headers}  expected_status=200
    Set Test Variable  ${response_headers}  ${resp.headers}

Header Should Contain
    [Arguments]  ${headers}
    FOR  ${header}  IN  @{headers}
        Should Contain  ${response_headers}  ${header}
    END

Header Should Not Contain
    [Arguments]  ${headers}
    FOR  ${header}  IN  @{headers}
        Should Not Contain  ${response_headers}  ${header}
    END
