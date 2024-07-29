*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Keeper Key/Value PUT Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-kvs-put.log

*** Test Cases ***
KVsPUT001 - Create a new configuration
    Given Set Test Variable  ${path}  testKVsPutService/Writable/LogLevel
    And Set Test Variable  ${set_value}  ERROR
    When Update Service Configuration On Keeper  ${path}  ${set_value}
    Then Should Return Status Code "200" And response
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Query Configuration And Value Should Be Correct
    [Teardown]  Delete Service Configuration On Keeper  ${path}

KVsPUT002 - Update a existed configuration and validate value should be updated
    Given Set Test Variable  ${path}  testKVsPutService/Writable/LogLevel
    And Update Service Configuration On Keeper  ${path}  ERROR
    And Set Test Variable  ${set_value}  WARN
    When Update Service Configuration On Keeper  ${path}  ${set_value}
    Then Should Return Status Code "200" And response
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Query Configuration And Value Should Be Correct
    [Teardown]  Delete Service Configuration On Keeper  ${path}

ErrKVsPUT001 - Should return error when updating configuration without JSON body
    When Update Configuration  testKVsPutService/Writable/LogLevel  key:value
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Query Configuration And Value Should Be Correct
    Query Service Configuration On Keeper  ${path}
    ${decode_value}  Evaluate  base64.b64decode('${content}[response][0][value]').decode('utf-8')  modules=base64
    Should Be Equal As Strings  ${set_value}  ${decode_value}

Update Configuration
    [Arguments]  ${path}  ${body}
    ${headers}  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${url}  Set Variable  ${URI_SCHEME}://${BASE_URL}:${CORE_KEEPER_PORT}
    Create Session  Keeper  url=${url}  disable_warnings=true
    ${resp}  PUT On Session  Keeper  ${KEEPER_CONFIG_BASE_ENDPOINT}/${path}
    ...   json=${body}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

