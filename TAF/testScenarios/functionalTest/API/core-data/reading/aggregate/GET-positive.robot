*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Delete all events by age
Suite Teardown  Run Teardown Keywords
Force Tags  historian

*** Variables ***
${SUITE}          Core-Data Aggregate Reading GET Postive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-aggregate-reading-positive.log
${serviceUrl}  ${coreDataUrl}

*** Test Cases ***
AggregateReadingGET001 - Get all readings with MIN aggregate function
#reading/all
    Given Set Test Variable  ${func_type}  min
    And Set Test Variable  @{test_devices}  Device-Test-001  Device-Test-002
    And Create Multiple Events With Different Resources With Devices  ${test_devices}
    When Query All Readings With aggregateFunc=${func_type}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 4
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET002 - Get all readings with MAX aggregate function
#reading/all
    Given Set Test Variable  ${func_type}  max
    And Set Test Variable  @{test_devices}  Device-Test-001  Device-Test-002
    And Create Multiple Events With Different Resources With Devices  ${test_devices}
    When Query All Readings With aggregateFunc=${func_type}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Should Be Equal  ${content}[aggregateFunc]  ${func_type}
    And Returned Readings Count Should Be 4
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET003 - Get device readings with COUNT aggregate function
#reading/device/name/{name}
    Given Set Test Variable  ${func_type}  count
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Create Multiple Events With Different Resources With Devices  ${test_devices}
    When Query readings by device name with aggregateFunc=${func_type}  ${test_devices}[0]
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 2
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET004 - Get device readings with SUM aggregate function
#reading/device/name/{name}
    Given Set Test Variable  ${func_type}  sum
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Create Multiple Events With Different Resources With Devices  ${test_devices}
    When Query readings by device name with aggregateFunc=${func_type}  ${test_devices}[0]
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 2
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET005 - Get resource readings with AVG aggregate function
#reading/resourceName/{resourceName}
    Given Set Test Variable  ${func_type}  avg
    And Set Test Variable  ${test_resource}  Simple-Reading
    And Create Multiple Events With Different Devices and Same Resource
    When Query readings by resourceName with aggregateFunc=${func_type}  ${test_resource}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 3
    And Each Device for Resource ${test_resource} Should Return Only One Reading With Func as Numeric Value  ${test_devices}
    [Teardown]  Delete All Events By Age

AggregateReadingGET006 - Get resource readings with MIN aggregate function
#reading/resourceName/{resourceName}
    Set Test Variable  ${func_type}  min
    And Set Test Variable  ${test_resource}  Simple-Reading
    Given Create Multiple Events With Different Devices and Same Resource
    When Query readings by resourceName with aggregateFunc=${func_type}  ${test_resource}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 3
    And Each Device for Resource ${test_resource} Should Return Only One Reading With Func as Numeric Value  ${test_devices}
    [Teardown]  Delete All Events By Age

AggregateReadingGET007 - Get device and resource readings with MAX aggregate function
#reading/device/name/{name}/resourceName/{resourceName}
    Set Test Variable  ${func_type}  max
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Create Multiple Events With Different Resources With Devices  ${test_devices}
    @{expected_resources}=  Create List  ${test_resources}[0]
    When Query Readings By deviceName And resourceName with aggregateFunc=${func_type}  ${test_devices}[0]  ${test_resources}[0]
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 1
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${expected_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET008 - Get device resource readings with COUNT aggregate function
#reading/device/name/{name}/resourceName/{resourceName}
    Set Test Variable  ${func_type}  count
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Create Multiple Events With Different Resources With Devices  ${test_devices}
    @{expected_resources}=  Create List  ${test_resources}[0]
    When Query Readings By deviceName And resourceName with aggregateFunc=${func_type}  ${test_devices}[0]  ${test_resources}[0]
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal  ${content}[aggregateFunc]  ${func_type}
    And Returned Readings Count Should Be 1
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${expected_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET009 - Get time range readings with SUM aggregate function
#reading/start/{start}/end/{end}
    Given Set Test Variable  ${func_type}  sum
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Create Multiple Events With Different Resources Twice To Get Start End Time
    When Query readings by start/end time with aggregateFunc=${func_type}  ${start_time}  ${end_time}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 2
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age

AggregateReadingGET010 - Get time range readings with AVG aggregate function
#reading/start/{start}/end/{end}
    Given Set Test Variable  ${func_type}  avg
    And Set Test Variable  @{test_devices}  Device-Test-001
    And Create Multiple Events With Different Resources Twice To Get Start End Time
    When Query readings by start/end time with aggregateFunc=${func_type}  ${start_time}  ${end_time}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Returned Readings Count Should Be 2
    And Each Resource for Devices Should Return Only One Reading With Func as Numeric Value  ${test_devices}  ${test_resources}
    [Teardown]  Delete All Events By Age
