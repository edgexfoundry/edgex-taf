*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Event POST Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-post-positive.log
${api_version}    v2

*** Test Cases ***
EventPOST001 - Create events
    [Tags]  SmokeTest
    Given Generate Multiple Events Sample With Simple Readings
    When Create Events
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    #[Teardown]  Delete Events

EventPOST002 - Create event with binary data
    Given Generate Multiple Events Sample With Binary Readings
    When Create Events
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    #[Teardown]  Delete Events

*** Keywords ***
Generate Multiple Events Sample With Binary Readings
    ${event1}=  Generate event sample  Event  Device-Test-001  Profile-Test-001  Binary Reading
    ${event2}=  Generate event sample  Event With Tags  Device-Test-002  Profile-Test-002  Binary Reading  Binary Reading
    ${events}=  Create List  ${event1}  ${event2}
    Set test variable  ${events}  ${events}

