*** Settings ***
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Skip If  $SECURITY_SERVICE_NEEDED != 'true'
             ...        AND  Setup Suite
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Proxy Auth - ACL
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/proxy-auth-acl.log
${proxyAuthUrl}   ${URI_SCHEME}://${BASE_URL}:8443
${keyUri}  /key

*** Test Cases ***
ACL001 - Send query API by external JWT token
    Given Generate External JWT Token
    And Get Token
    And Create Key  ${key_body}
    And Set Test Variable  ${jwt_token}  ${external_token}
    When Query All Device Profiles
    Then Should Return Status Code "200"
    And Should Be True  len(${content}[profiles]) > 0
    [Teardown]  Remove Token

*** Keywords ***
Generate External JWT Token
    ${timestamp}  Get Current Milliseconds Epoch Time
    ${expire}  Evaluate  ${timestamp}+600000
    ${issuer}  Set Variable  tester-${timestamp}
    ${output}  Run Process  python ${WORK_DIR}/TAF/utils/src/setup/jwt-generator.py ${issuer} ${expire}
               ...          shell=True  stderr=STDOUT  timeout=10s
    Log  ${output.stdout}
    ${private_key}  Get Regexp Matches  ${output.stdout}
                    ...  (?s)-----BEGIN RSA PRIVATE KEY-----(.*?)-----END RSA PRIVATE KEY-----  flags=MULTILINE
    ${public_key}  Get Regexp Matches  ${output.stdout}
                   ...  (?s)-----BEGIN PUBLIC KEY-----(.*?)-----END PUBLIC KEY-----  flags=MULTILINE
    ${jwt_token}  Get Regexp Matches  ${output.stdout}  jwt_token:\s*([a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+)
    ${token}  Remove String  ${jwt_token[0]}  jwt_token:
    ${keys}  Create Dictionary  private_key=${private_key[0]}  public_key=${public_key[0]}
             ...                jwt_token=${token}

    ${key_value}  Set Variable  ${keys}[public_key]
    ${keyData}  Create Dictionary   issuer=${issuer}  type=verification  key=${key_value}
    ${key_body}  Create Dictionary  apiVersion=${API_VERSION}  keyData=${keyData}
    Set Test Variable  ${key_body}  ${key_body}
    Set Test Variable  ${external_token}  ${keys}[jwt_token]

Create Key
    [Arguments]  ${entity}
    # Replace json with data to avoid requests automatically converting \n to \\n
    ${json_payload}    Evaluate    json.dumps(${entity}, ensure_ascii=False)    json
    Create Session  Proxy Auth  url=${proxyAuthUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}  POST On Session  Proxy Auth  ${keyUri}  data=${json_payload}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  Log  ${content}
