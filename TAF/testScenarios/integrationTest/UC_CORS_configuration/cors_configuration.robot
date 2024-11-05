*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords   Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'false'  Enable CORS For Individual Service
Suite Teardown  Run Keywords  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'false'  Disable CORS For Individual Service
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}  CORS Configuration
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/cors_configuration.log
${coreMetadataUrl}  ${URI_SCHEME}://${BASE_URL}:${CORE_METADATA_PORT}

*** Test Cases ***
CORS001-Enable CORS and receive a prefligt request
    ${header_keys}  Create List  Access-Control-Request-Method  Origin
    ${header_values}  Create List  GET  http://localhost
    ${expected_headers}  Create List  Vary  Access-Control-Allow-Headers  Access-Control-Allow-Methods
                         ...   Access-Control-Allow-Origin  Access-Control-Allow-Credentials  Access-Control-Max-Age
    ${unexpected_headers}  Create List  Access-Control-Expose-Headers
    When Send OPTIONS Request With Headers  ${header_keys}  ${header_values}
    Then Should Return Status Code "200" or "204"
    And Header Should Contain  ${expected_headers}
    And Header Should Not Contain  ${unexpected_headers}

CORS002-Enable CORS and receive an actual request
    ${header_keys}  Create List  Access-Control-Request-Method  Origin
    ${header_values}  Create List  GET  http://localhost
    ${expected_headers}  Create List  Access-Control-Expose-Headers  Access-Control-Allow-Origin
                         ...     Access-Control-Allow-Credentials  Vary
    When Send GET Request With Headers  ${header_keys}  ${header_values}
    Then Should Return Status Code "200" or "204"
    And Header Should Contain  ${expected_headers}

CORS003-Enable CORS and receive a prefligt request with CORSAllowCredentials=false
    [Setup]  Run Keywords  Set Service.CORSConfiguration.CORSAllowCredentials to false For core-metadata On Registry Service
             ...      AND  Restart Services  core-metadata
    ${header_keys}  Create List  Access-Control-Request-Method  Origin
    ${header_values}  Create List  GET  http://localhost
    ${expected_headers}  Create List  Vary  Access-Control-Allow-Headers  Access-Control-Allow-Methods
                         ...   Access-Control-Allow-Origin  Access-Control-Max-Age
    ${unexpected_headers}  Create List  Access-Control-Expose-Headers
    When Send OPTIONS Request With Headers  ${header_keys}  ${header_values}
    Then Should Return Status Code "200" or "204"
    And Header Should Contain  ${expected_headers}
    And Header Should Not Contain  ${unexpected_headers}

CORS004-Enable CORS and receive an actual request with CORSAllowCredentials=false
    [Setup]  Run Keywords  Set Service.CORSConfiguration.CORSAllowCredentials to false For core-metadata On Registry Service
             ...      AND  Restart Services  core-metadata
    ${header_keys}  Create List  Access-Control-Request-Method  Origin
    ${header_values}  Create List  GET  http://localhost
    ${expected_headers}  Create List  Access-Control-Expose-Headers  Access-Control-Allow-Origin  Vary
    When Send GET Request With Headers  ${header_keys}  ${header_values}
    Then Should Return Status Code "200" or "204"
    And Header Should Contain  ${expected_headers}

CORS005-Not enable CORS
    [Setup]  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Skip
             ...       ELSE  Disable CORS For Individual Service
    ${unexpected_headers}  Create List  Access-Control-Expose-Headers  Access-Control-Allow-Origin
                         ...     Access-Control-Allow-Credentials  Vary
    When Send GET Request Without CORS Headers
    Then Should Return Status Code "200" or "204"
    And Header Should Not Contain  ${unexpected_headers}

*** Keywords ***
Set Service.CORSConfiguration.${config} to ${value} For ${service_name} On Registry Service
    ${path}=  Set Variable  /${service_name}/Service/CORSConfiguration/${config}
    Update Service Configuration  ${path}  ${value}

Send ${method} Request With Headers
    [Arguments]  ${header_keys}  ${header_values}
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    FOR  ${key}  ${value}  IN ZIP  ${header_keys}  ${header_values}
        Set To Dictionary  ${headers}  ${key}=${value}
    END
    Create Session  Ping  url=${coreMetadataUrl}  disable_warnings=true
    ${resp}  Run Keyword If  "${method}" == "GET"  GET On Session  Ping  api/${API_VERSION}/ping  headers=${headers}
             ...    ELSE IF  "${method}" == "OPTIONS"  OPTIONS On Session  Ping  api/${API_VERSION}/ping  headers=${headers}
             ...       ELSE  Fail  Invalid Method: ${method}
    Set Test Variable  ${response_headers}  ${resp.headers}
    Set Test Variable  ${response}  ${resp.status_code}


Send GET Request Without CORS Headers
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    Create Session  Ping  url=${coreMetadataUrl}  disable_warnings=true
    ${resp}  GET On Session  Ping  api/${API_VERSION}/ping  headers=${headers}
    Set Test Variable  ${response_headers}  ${resp.headers}
    Set Test Variable  ${response}  ${resp.status_code}

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

Enable CORS For Individual Service
    Set Service.CORSConfiguration.EnableCORS to true For core-metadata On Registry Service
    Set Service.CORSConfiguration.CORSAllowCredentials to true For core-metadata On Registry Service
    Restart Services  core-metadata

Disable CORS For Individual Service
    Set Service.CORSConfiguration.EnableCORS to false For core-metadata On Registry Service
    Restart Services  core-metadata
