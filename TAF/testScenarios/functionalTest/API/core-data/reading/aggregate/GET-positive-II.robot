*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Delete all events by age
Suite Teardown  Run Teardown Keywords
Force Tags    historian

*** Variables ***
${SUITE}          Core-Data Aggregate Reading GET Postive II Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-aggregate-reading-positiveII.log

*** Test Cases ***
AggregateReadingGET011 - Get resource time range readings with MIN aggregate function
#reading/resourceName/{resourceName}/start/{start}/end/{end}
    Given Set Test Variable  ${func_type}  min
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Set Test Variable  @{query_resource}  Simple-Reading
    And Create Multiple Events With Different Resources Twice To Get Start End Time
    When Query readings by resource ${query_resource}[0] and start ${start_time}/end ${end_time} with aggregateFunc=${func_type}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 1
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${query_resource}
    [Teardown]  Delete All Events By Age

AggregateReadingGET012 - Get resource time range readings with MAX aggregate function
#reading/resourceName/{resourceName}/start/{start}/end/{end}
    Given Set Test Variable  ${func_type}  max
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Set Test Variable  @{query_resource}  Simple-Reading
    And Create Multiple Events With Different Resources Twice To Get Start End Time
    When Query readings by resource ${query_resource}[0] and start ${start_time}/end ${end_time} with aggregateFunc=${func_type}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 1
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${query_resource}
    [Teardown]  Delete All Events By Age

AggregateReadingGET013 - Get device resource time range readings with COUNT aggregate function
#reading/device/name/{name}/resourceName/{resourceName}/start/{start}/end/{end}
    Given Set Test Variable  ${func_type}  count
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Set Test Variable  @{query_resource}  Simple-Reading
    And Create Multiple Events With Different Resources Twice To Get Start End Time
    When Query readings by device ${test_devices}[0] and resource ${query_resource}[0] between ${start_time}/${end_time} with aggregateFunc=${func_type}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 1
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${query_resource}
    [Teardown]  Delete All Events By Age

AggregateReadingGET014 - Get device resource time range readings with SUM aggregate function
#reading/device/name/{name}/resourceName/{resourceName}/start/{start}/end/{end}
    Given Set Test Variable  ${func_type}  sum
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Set Test Variable  @{query_resource}  Simple-Reading
    And Create Multiple Events With Different Resources Twice To Get Start End Time
    When Query readings by device ${test_devices}[0] and resource ${query_resource}[0] between ${start_time}/${end_time} with aggregateFunc=${func_type}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 1
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${query_resource}
    [Teardown]  Delete All Events By Age

AggregateReadingGET015 - Get device time range readings with AVG aggregate function
#reading/device/name/{name}start/{start}/end/{end}
    Given Set Test Variable  ${func_type}  avg
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Create Multiple Events With Different Resources Twice To Get Start End Time
    When Query readings by deviceName and start/end with aggregateFunc=${func_type}  ${test_devices}[0]  ${start_time}  ${end_time}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 2
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET016 - Get device time range readings with MIN aggregate function
#reading/device/name/{name}start/{start}/end/{end}
    Given Set Test Variable  ${func_type}  min
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Create Multiple Events With Different Resources Twice To Get Start End Time
    When Query readings by deviceName and start/end with aggregateFunc=${func_type}  ${test_devices}[0]  ${start_time}  ${end_time}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 2
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET017 - Query reading with aggregate and offset
    Given Set Test Variable  ${func_type}  min
    And Set Test Variable  @{test_devices}  Device-Test-001  Device-Test-002
    And Create Multiple Events With Different Resources With Devices  ${test_devices}
    When Query All Readings With aggregateFunc=${func_type}&offset=1
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 3
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET018 - Query reading with aggregate and limit
    Given Set Test Variable  ${func_type}  avg
    And Set Test Variable  @{test_devices}  Device-Test-001  Device-Test-002
    And Create Multiple Events With Different Resources With Devices  ${test_devices}
    When Query All Readings With aggregateFunc=${func_type}&limit=2
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 2
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET019 - Aggregate on string fields should return empty string
#For non-numeric value types (e.g., String, Bool), the aggregate result will be empty string.
    Given Generate event sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  String Reading
    And Create Event With Service-Test-001 and Profile-Test-001 and Device-Test-001 and Command-Test-001
    When Query All Readings With aggregateFunc=sum
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal  ${content}[readings][0][valueType]  String
    And Should Be Equal  ${content}[readings][0][value]  ${EMPTY}
    [Teardown]  Delete All Events By Age

AggregateReadingGET020 - Aggregate on boolean fields should return empty string
#For non-numeric value types (e.g., String, Bool), the aggregate result will be empty string.
    Given Generate event sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  Bool Reading
    And Create Event With Service-Test-001 and Profile-Test-001 and Device-Test-001 and Command-Test-001
    When Query All Readings With aggregateFunc=avg
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal  ${content}[readings][0][valueType]  Bool
    And Should Be Equal  ${content}[readings][0][value]  ${EMPTY}
    [Teardown]  Delete All Events By Age
