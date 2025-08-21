*** Settings ***
Force Tags    Skipped

*** Variables ***
${SUITE}          Proxy Auth - ACL
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/proxy-auth-acl.log

*** Test Cases ***
ACL001 - Send query API by external JWT token
    Given Generate External JWT Token
    And Generate Validation Key
    And Get Proxy Token Using api-gateway-token Script
    And Add Validation Key
    When Query All Device Profiles By External JWT Token
    Then Device Profiles Should Be Returned
