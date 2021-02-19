*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Event DELETE Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-delete-negative.log
${api_version}    v2

*** Test Cases ***
ErrEventDELETE001 - Delete event by ID fails (Non-existent ID)
    ${random_uuid}=  Evaluate  str(uuid.uuid4())
    When Run Keyword And Expect Error  *  Delete Event By ID  ${random_uuid}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventDELETE002 - Delete event by ID fails (Not UUID)
    When Run Keyword And Expect Error  *  Delete Event By ID  InvalidID
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventDELETE003 - Delete events by age fails
    When Run Keyword And Expect Error  *  Delete All Events By Age  InvalidAge
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
