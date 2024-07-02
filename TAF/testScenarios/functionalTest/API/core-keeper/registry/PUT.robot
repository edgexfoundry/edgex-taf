*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Core Keeper Registry PUT Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-registry-put.log

*** Test Cases ***
RegistryPUT001 - Update interval for registered service
    Given Register A Service
    When Update Interval For Registered Service
    Then Should Return Status Code "204"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Interval Should Be Updated
    [Teardown]  Delete Registered Service

ErrRegistryPUT001 - Update interval for unregistered service
    When Update Interval For Unregistered Service
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrRegistryPUT002 - Should return error when registering service without host
    Given Register A Service
    When Update Registered Service Without Host Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Registered Service

ErrRegistryPUT003 - Should return error when registering service without port
    Given Register A Service
    When Update Registered Service Without Port Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Registered Service

ErrRegistryPUT004 - Should return error when registering service without healthCheck
    Given Register A Service
    When Update Registered Service Without healthCheck Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Registered Service

ErrRegistryPUT005 - Should return error when registering service without healthCheck interval
    Given Register A Service
    When Update Registered Service Without healthCheck Interval Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Registered Service

ErrRegistryPUT006 - Should return error when registering service without healthCheck path
    Given Register A Service
    When Update Registered Service Without healthCheck Path Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Registered Service

ErrRegistryPUT007 - Should return error when registering service without healthCheck type
    Given Register A Service
    When Update Registered Service Without healthCheck Type Field
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Registered Service
