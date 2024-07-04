*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Core Keeper Key/Value PUT Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-kvs-put.log

*** Test Cases ***
KVsPUT001 - Create a new configuration
    When Create New Configuration
    Then Should Return Status Code "200" And response
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Query Configuration And Value Should Be Correct
    [Teardown]  Delete Configuration

KVsPUT002 - Update a existed configuration and validate value should be updated
    Given Create New Configuration
    When Update A Exited Configuration
    Then Should Return Status Code "200" And response
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Query Configuration And Value Should Be Correct
    [Teardown]  Delete Configuration

ErrKVsPUT001 - Should return error when updating configuration without JSON body
    # "value":"test"
    When Update A Exited Configuration Without JSON Body
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrKVsPUT002 - Should return error when updating configuration with invalid JSON format
    # { key: value }
    When Update A Exited Configuration Without JSON Body
    Then Should Return Status Code "500"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
