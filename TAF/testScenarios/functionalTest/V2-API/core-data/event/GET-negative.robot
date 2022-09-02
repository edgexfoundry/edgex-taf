*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Event GET Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-negative.log

*** Test Cases ***
ErrEventGET001 - Query event by ID fails (Non-existent ID)
    ${random_uuid}=  Evaluate  str(uuid.uuid4())
    When Query Event By Event Id "${random_uuid}"
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET002 - Query event by ID fails (Not UUID)
    When Query Event By Event Id "InvalidID"
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET003 - Query events by start/end time fails (Invalid Start)
    ${end_time}=  Get current nanoseconds epoch time
    When Run Keyword And Expect Error  *  Query Events By Start/End Time  InvalidStart  ${end_time}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET004 - Query events by start/end time fails (Invalid End)
    ${start_time}=  Get current nanoseconds epoch time
    When Run Keyword And Expect Error  *  Query Events By Start/End Time  ${start_time}  InvalidEnd
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET005 - Query events by start/end time fails (Start>End)
    ${start_time}=  Get current nanoseconds epoch time
    ${end_time}=  Get current nanoseconds epoch time
    When Run Keyword And Expect Error  *  Query Events By Start/End Time  ${end_time}  ${start_time}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET006 - Query event fails when persistData is false
    ${path}=  Set Variable  /v1/kv/edgex/core/${CONSUL_CONFIG_VERSION}/core-data/Writable/PersistData
    Given Update Service Configuration On Consul  ${path}  false
    And Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  Simple Reading
    And Create Event With Device-Test-001 And Profile-Test-001 And Command-Test-001
    When Query Event By Event Id "${id}"
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete All Events By Age
    ...                  AND  Update Service Configuration On Consul  ${path}  true
