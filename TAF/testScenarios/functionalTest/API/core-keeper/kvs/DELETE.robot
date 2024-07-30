*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Keeper Key/Value DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-kvs-delete.log

*** Test Cases ***
KVsDELETE001 - Delete an existed configuration
    Given Set Test Variable  ${path}  testKVsDelService/Writable/Key1
    And Set Test Variable  ${set_value}  value1
    And Update Service Configuration On Keeper  ${path}  ${set_value}
    When Delete Service Configuration On Keeper  ${path}
    Then Should Return Status Code "200" And response
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Configuration Should Not Exist

ErrKVsDELETE001 - Should return error when deleting an absent configuration
    When Delete Service Configuration On Keeper  testKVsDelService/Writable/KeyAbsent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrKVsDELETE002 - Should return error when deleting configuration which contains associated configuration
    Given Set Test Variable  ${path}  testKVsDelService/Writable
    And Update Service Configuration On Keeper  ${path}/Key1  value1
    When Delete Service Configuration On Keeper  ${path}
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Configuration Should Not Exist
    Query Service Configuration On Keeper  ${path}
    Should Return Status Code "404"
