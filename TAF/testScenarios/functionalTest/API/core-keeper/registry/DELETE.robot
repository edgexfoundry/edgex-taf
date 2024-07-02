*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Core Keeper Registry DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-registry-delete.log

*** Test Cases ***
RegistryDELETE001 - Delete a registered service
    When Delete A Registered Service
    Then Should Return Status Code "204"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryDELETE001 - Delete an unregistered service
    When Delete An Unregistered Service
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
