*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core-Data Event POST Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-post-positive.log

*** Test Cases ***
EventPOST001 - Create event
    [Tags]  SmokeTest
    Given Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  Simple Reading  Simple Float Reading
    When Create Event With Service-Test-001 And Profile-Test-001 And Device-Test-001 And Command-Test-001
    Then Should Return Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

EventPOST002 - Create event with binary data
    Given Generate Event Sample  Event With Tags  Device-Test-002  Profile-Test-002  Command-Test-002  Binary Reading
    When Create Event With Service-Test-002 And Profile-Test-002 And Device-Test-002 And Command-Test-002
    Then Should Return Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

