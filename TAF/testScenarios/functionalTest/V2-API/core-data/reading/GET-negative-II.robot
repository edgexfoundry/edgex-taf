*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Delete all events by age
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Reading GET Negative II Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-reading-negative-II.log

*** Test Cases ***
ErrReadingGET013 - Query readings by device name and resource name between start/end time fails (Invalid Start)
    ${end_time}=  Get current nanoseconds epoch time
    When Query readings by device and resource between start/end time  Test_Device  Test_Resource  InvalidStart  ${end_time}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET014 - Query readings by device name and resource name between start/end time fails (Invalid End)
    ${start_time}=  Get current nanoseconds epoch time
    When Query readings by device and resource between start/end time  Test_Device  Test_Resource  ${start_time}  InvalidEnd
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET015 - Query readings by device name and resource name between start/end time fails (Start>End)
    ${start_time}=  Get current nanoseconds epoch time
    ${end_time}=  Get current nanoseconds epoch time
    When Query readings by device and resource between start/end time  Test_Device  Test_Resource  ${end_time}  ${start_time}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET016 - Query readings by device name and resource name between start/end time with invalid offset range
    Given Create Multiple Events Twice To Get Start/End Time
    When Query readings by device Device-Test-001 and resource Simple-Reading between ${start_time}/${end_time} with offset=10
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age
