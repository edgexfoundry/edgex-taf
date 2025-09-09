*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  historian

*** Variables ***
${SUITE}          Core-Data Aggregate Reading GET Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-aggregate-reading-negative.log
${serviceUrl}  ${coreDataUrl}

*** Test Cases ***
ErrAggregateReadingGET001 - Query all reading with invalid aggregate function
#reading/all
    When Run Keyword And Expect Error  *  Query All Readings With aggregateFunc=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrAggregateReadingGET002 - Query device reading with invalid aggregate function
#reading/device/name/{name}
    When Query readings by device name with aggregateFunc=Invalid  Test_Device
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrAggregateReadingGET003 - Query resource reading with invalid aggregate function
#reading/resourceName/{resourceName}
    When Query readings by resourceName with aggregateFunc=Invalid  Test_Resource
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrAggregateReadingGET004 - Query device and resource reading with invalid aggregate function
#reading/device/name/{name}/resourceName/{resourceName}
    When Query Readings By deviceName And resourceName with aggregateFunc=Invalid  Test_Device  Test_Resource
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrAggregateReadingGET005 - Query time range reading with invalid aggregate function
#reading/start/{start}/end/{end}
    ${start_time}=  Get current nanoseconds epoch time
    ${end_time}=  Evaluate  ${start_time}+100000000
    When Query readings by start/end time with aggregateFunc=Invalid  ${start_time}  ${end_time}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrAggregateReadingGET006 - Query resource and time range reading with invalid aggregate function
#reading/resourceName/{resourceName}/start/{start}/end/{end}
    ${start_time}=  Get current nanoseconds epoch time
    ${end_time}=  Evaluate  ${start_time}+100000000
    When Query readings by resource Test_Resource and start ${start_time}/end ${end_time} with aggregateFunc=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrAggregateReadingGET007 - Query device and resource and time range reading with invalid aggregate function
#reading/device/name/{name}/resourceName/{resourceName}/start/{start}/end/{end}
    ${start_time}=  Get current nanoseconds epoch time
    ${end_time}=  Evaluate  ${start_time}+100000000
    When Query readings by device Test_Device and resource Test_Resource between ${start_time}/${end_time} with aggregateFunc=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrAggregateReadingGET008 - Query device and time range reading with invalid aggregate function
#reading/device/name/{name}/start/{start}/end/{end}
    ${start_time}=  Get current nanoseconds epoch time
    ${end_time}=  Evaluate  ${start_time}+100000000
    When Query readings by deviceName and start/end with aggregateFunc=Invalid  Test_device  ${start_time}  ${end_time}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
