*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-keeper/coreKeeperAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Keeper Registry GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-registry-get.log

*** Test Cases ***
RegistryGET001 - Query all registered services
    Given Register Multiple Services
    When Query All Registered Services
    Then Should Return Status Code "200" And registrations
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Registered Services Are Listed And Count Should Match totalCount
    [Teardown]  Deregister Multiple Configurations

RegistryGET002 - Query registered service by serviceId
    Given Set Test Variable  ${serviceId}  testRegistryGetService
    And Generate Registry Data  ${serviceId}  test-service-host  ${12345}
    And Register A New Service  ${Registry}
    When Query Registered Service By ServiceId  ${serviceId}
    Then Should Return Status Code "200" And registration
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Strings  ${serviceId}  ${content}[registration][serviceId]
    [Teardown]  Deregister Service  ${serviceId}

ErrRegistryGET001 - Should return error when querying unregistered service
    When Query Registered Service By ServiceId  unregistered_service
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
All Registered Services Are Listed And Count Should Match totalCount
    ${service_count}  Get Length  ${content}[registrations]
    Should Be Equal As Integers  ${service_count}  ${content}[totalCount]

Register Multiple Services
    ${Ids}  Create List  service1  service2  service3
    FOR  ${id}  IN  @{Ids}
        Generate Registry Data  ${id}  ${id}-host  ${12345}
        Register A New Service  ${Registry}
    END
    Set Test Variable  ${serviceIds}  ${Ids}

Deregister Multiple Configurations
    FOR  ${id}  IN  @{serviceIds}
        Deregister Service  ${id}
    END

