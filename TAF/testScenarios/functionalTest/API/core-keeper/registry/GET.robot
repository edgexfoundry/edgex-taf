*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags    Skipped

*** Variables ***
${SUITE}          Core Keeper Registry GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-registry-get.log

*** Test Cases ***
RegistryGET001 - Query all registered services
    When Query All Registered Services
    Then Should Return Status Code "200" And registrations
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Registered Services Are Listed And Count Should Match totalCount

RegistryGET002 - Query registered service by name
    When Query Registered Service By Name
    Then Should Return Status Code "200" And registrations
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Registered Service Should Be Found

ErrRegistryGET001 - Should return error when querying unregistered service
    When Query Unregistered Service
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
