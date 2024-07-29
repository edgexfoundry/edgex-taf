*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-keeper/coreKeeperAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Keeper Registry DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-registry-delete.log

*** Test Cases ***
RegistryDELETE001 - Deregister Service
    Given Set Test Variable  ${serviceId}  testRegistryDelService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    When Deregister Service  ${serviceId}
    Then Should Return Status Code "204"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Service Should Be Deregistered

ErrRegistryDELETE001 - Delete an unregistered service
    When Deregister Service  not_registry_service
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Service Should Be Deregistered
    Query Registered Service By ServiceId  ${serviceId}
    Should Return Status Code "404"
