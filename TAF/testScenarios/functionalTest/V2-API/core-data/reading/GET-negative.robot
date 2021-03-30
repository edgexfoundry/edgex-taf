*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Reading GET Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-reading-negative.log
${api_version}    v2

*** Test Cases ***
ErrReadingGET001 - Query all readings with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Readings With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET002 - Query all readings with offset out of range
    When Run Keyword And Expect Error  *  Query All Readings With offset=-1
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET003 - Query all readings with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Readings With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET004 - Query all readings with limit out of range
    When Run Keyword And Expect Error  *  Query All Readings With limit=50001
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET005 - Query all readings with invalid offset range
    Given Create Multiple Events
    When Run Keyword And Expect Error  *  Query All Readings With offset=10
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ErrReadingGET006 - Query readings by start/end time fails (Invalid Start)
    ${end_time}=  Get current nanoseconds epoch time
    When Run Keyword And Expect Error  *  Query Readings By Start/End Time  InvalidStart  ${end_time}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET007 - Query readings by start/end time fails (Invalid End)
    ${start_time}=  Get current nanoseconds epoch time
    When Run Keyword And Expect Error  *  Query Readings By Start/End Time  ${start_time}  InvalidEnd
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET008 - Query readings by start/end time fails (Start>End)
    ${start_time}=  Get current nanoseconds epoch time
    ${end_time}=  Get current nanoseconds epoch time
    When Run Keyword And Expect Error  *  Query Readings By Start/End Time  ${end_time}  ${start_time}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

