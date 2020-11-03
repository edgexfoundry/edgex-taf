*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}         Core-Data Event GET Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-negative.log
${api_version}    v2

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

ErrEventGET003 - Query all events with specified device by device name fails
    [Tags]  Skipped
    When Query All Events with Specified Device By Non-existent Device Name
    Then Should return Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET004 - Query events by start/end time fails (Invalid Start)
    [Tags]  Skipped
    When Query Events By Invalid Start Time
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET005 - Query events by start/end time fails (Invalid End)
    [Tags]  Skipped
    When Query Events By Invalid End Time
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET006 - Query events by start/end time fails (Start>End)
    [Tags]  Skipped
    When Query Events By Invalid Start/End Time
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventGET007 - Query a count of all of events with specified device by device name fails
    [Tags]  Skipped
    When Query All Events Count With Specified Device By Non-existent Device Name
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
