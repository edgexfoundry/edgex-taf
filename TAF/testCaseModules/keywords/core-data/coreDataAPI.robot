*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  Collections
Library  uuid
Library  TAF/testCaseModules/keywords/common/value_checker.py
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${coreDataUrl}  ${URI_SCHEME}://${BASE_URL}:${CORE_DATA_PORT}
${eventUri}    /api/${API_VERSION}/event
${readingUri}  /api/${API_VERSION}/reading
${serviceUrl}  ${coreDataUrl}

*** Keywords ***
Query all readings
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/all  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query all readings with ${params}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/all  params=${params}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query readings by resourceName
    [Arguments]  ${resource_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/resourceName/${resource_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query readings by device name
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/device/name/${device_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query Readings By deviceName And resourceName
    [Arguments]  ${device_name}   ${resource_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/device/name/${device_name}/resourceName/${resource_name}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query readings by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/start/${start_time}/end/${end_time}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Query readings by resource and start/end time
    [Arguments]  ${resource}  ${start_time}   ${end_time}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data
    ...       ${readingUri}/resourceName/${resource}/start/${start_time}/end/${end_time}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query readings by resource ${resource} and start ${start_time}/end ${end_time} with ${params}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data
    ...       ${readingUri}/resourceName/${resource}/start/${start_time}/end/${end_time}
    ...       params=${params}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query readings by device and resource between start/end time
    [Arguments]  ${device}  ${resource}  ${start_time}   ${end_time}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data
    ...       ${readingUri}/device/name/${device}/resourceName/${resource}/start/${start_time}/end/${end_time}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query readings by device ${device} and resource ${resource} between ${start_time}/${end_time} with ${params}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data
    ...       ${readingUri}/device/name/${device}/resourceName/${resource}/start/${start_time}/end/${end_time}
    ...       params=${params}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}

Query all readings count
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/count  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query readings count by device name
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/count/device/name/${device_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query readings by resourceName with ${params}
    [Arguments]  ${resource_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/resourceName/${resource_name}  params=${params}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

Query readings by device name with ${params}
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/device/name/${device_name}  params=${params}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

Query Readings By deviceName And resourceName with ${params}
    [Arguments]  ${device_name}   ${resource_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/device/name/${device_name}/resourceName/${resource_name}
    ...       params=${params}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

Query readings by start/end time with ${params}
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${readingUri}/start/${start_time}/end/${end_time}  params=${params}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

Query readings by deviceName and start/end with ${params}
    [Arguments]  ${device}  ${start_time}  ${end_time}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data
    ...       ${readingUri}/device/name/${device}/start/${start_time}/end/${end_time}
    ...       params=${params}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

# Event
Create event with ${serviceName} and ${profileName} and ${deviceName} and ${sourceName}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Data    ${eventUri}/${serviceName}/${profileName}/${deviceName}/${sourceName}  json=${event}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  log to console  ${content}

Query event by event id "${event_id}"
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${api}=  Set Variable   ${eventUri}/id/${event_id}
    ${resp}=  GET On Session  Core Data    ${api}   headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    RETURN  ${resp.status_code}  ${resp.content}

Query all events
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${eventUri}/all   headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query all events with ${params}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${eventUri}/all  params=${params}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query events by device name
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${eventUri}/device/name/${device_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query events by device name with parameters
    [Arguments]  ${device_name}  ${params}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${eventUri}/device/name/${device_name}  headers=${headers}
    ...       params=${params}  expected_status=200
    Set Response to Test Variables  ${resp}

Query events by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${eventUri}/start/${start_time}/end/${end_time}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Query all events count
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${eventUri}/count  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query events count by device name
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${eventUri}/count/device/name/${device_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Delete all events by age
    [Arguments]  ${age}=0
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Data  ${eventUri}/age/${age}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=202  fail  ${response}!=202: ${content}

Delete event by id
    [Arguments]  ${id}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Data  ${eventUri}/id/${id}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Delete events by device name
    [Arguments]  ${deviceName}
    Create Session  Core Data  url=${serviceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Data  ${eventUri}/device/name/${deviceName}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=202  fail  ${response}!=202: ${content}

# generate data for core-data
Generate event sample
    # event_data: Event, Event With Tags ; readings_type: Simple Reading, Simple Float Reading, Binary Reading
    [Arguments]  ${event_data}  ${deviceName}  ${profileName}  ${sourceName}  @{readings_type}
    ${uuid}=  Evaluate  str(uuid.uuid4())
    ${origin}=  Get current nanoseconds epoch time
    @{readings}=  Create List

    FOR  ${type}  IN  @{readings_type}
        ${reading}=  Load data file "core-data/readings_data.json" and get variable "${type}"
        Set to dictionary  ${reading}  origin=${origin}
        Set to dictionary  ${reading}  deviceName=${deviceName}
        Set to dictionary  ${reading}  profileName=${profileName}
        ${valueType}=  Evaluate  "${reading}[valueType]".upper()
        ${random_value}=  Get reading value with data type "${valueType}"
        ${string_value}=  Convert To String  ${random_value}
        Set to dictionary  ${reading}  value=${string_value}
        Append to List  ${readings}  ${reading}
    END
    ${event}=  Load data file "core-data/event_data.json" and get variable "${event_data}"
    Set to dictionary  ${event}         apiVersion=${API_VERSION}
    Set to dictionary  ${event}[event]  deviceName=${deviceName}
    Set to dictionary  ${event}[event]  profileName=${profileName}
    Set to dictionary  ${event}[event]  sourceName=${sourceName}
    Set to dictionary  ${event}[event]  id=${uuid}
    Set to dictionary  ${event}[event]  origin=${origin}
    Set to dictionary  ${event}[event]  readings=${readings}
    Set test variable  ${id}  ${uuid}
    Set test variable  ${event}  ${event}

Create multiple events
  FOR  ${index}  IN RANGE  0  3   # total: 6 events, 9 readings
    Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  Simple Reading
    Create Event With Service-Test-001 and Profile-Test-001 and Device-Test-001 and Command-Test-001
    Generate Event Sample  Event  Device-Test-002  Profile-Test-001  Command-Test-002  Simple Reading  Simple Float Reading
    Create Event With Service-Test-001 and Profile-Test-001 and Device-Test-002 and Command-Test-002
  END

Create Multiple Events With Different Resources With Devices
  [Arguments]  ${test_devices}
  @{resources}=  Create List  Simple Float Reading  Simple Reading
  @{test_readings}=  Create List
  @{test_resources}=  Create List
  FOR  ${test_device}  IN  @{test_devices}
    FOR  ${resource}  IN  @{resources}
      ${reading}=  Load data file "core-data/readings_data.json" and get variable "${resource}"
      ${resource_exists}=  Evaluate  "${reading}[resourceName]" in $test_resources
      IF  not ${resource_exists}
        Append To List  ${test_resources}  ${reading}[resourceName]
      END

      FOR  ${index}  IN RANGE  0  3
      Generate event sample  Event  ${test_device}  Profile-Test-001  Command-Test-001  ${resource}
      Append To List  ${test_readings}  ${event}[event][readings][0]
      Create Event With Service-Test-001 and Profile-Test-001 and ${test_device} and Command-Test-001
      END
    END
  END
  Set Test Variable  ${test_resources}
  Set Test Variable  ${test_readings}

Create Multiple Events With Different Resources Twice To Get Start End Time
    ${start_time}=  Get current nanoseconds epoch time
    Create Multiple Events With Different Resources With Devices  ${test_devices}
    @{first_test_readings}=  Set Variable  ${test_readings}
    Sleep  1s
    ${end_time}=  Get current nanoseconds epoch time
    @{compare_device}=  Create List  Device-Test-002
    Create Multiple Events With Different Resources With Devices  ${compare_device}
    Set Test Variable  ${test_readings}  ${first_test_readings}
    Set Test Variable  ${start_time}
    Set Test Variable  ${end_time}

Create Multiple Events With Different Devices and Same Resource
  @{test_devices}=  Create List  Device-Test-001  Device-Test-002  Device-Test-003
  @{test_readings}=  Create List
  FOR  ${index}  IN RANGE  0  3
    FOR  ${device}  IN  @{test_devices}
      Generate event sample  Event  ${device}  Profile-Test-001  Command-Test-001  Simple Reading
      Append To List  ${test_readings}  ${event}[event][readings][0]
      Create Event With Service-Test-001 and Profile-Test-001 and ${device} and Command-Test-001
    END
  END
  Set Test Variable  ${test_devices}
  Set Test Variable  ${test_readings}

Create multiple events twice to get start/end time
  ${start_time}=  Get current nanoseconds epoch time
  Create Multiple Events
  ${end_time}=  Get current nanoseconds epoch time
  Create Multiple Events
  Set Test Variable  ${start_time}  ${start_time}
  Set Test Variable  ${end_time}  ${end_time}

Query device events after executing deletion, and no event found
    Query all events
    should be equal as integers  ${response}  200
    ${events_length}   GET LENGTH  ${content}[events]
    run keyword if  ${events_length} != 0  fail  Found events after executing deletion

#aggregate
Get Expected Aggregate ValueType
    [Arguments]  ${valueType}
    IF  "${func_type}" == "count"
        ${expected_valueType}=  Set Variable  Uint64
    ELSE IF  "${func_type}" == "avg"
        ${expected_valueType}=  Set Variable  Float64
    ELSE IF  "${func_type}" in ["sum", "min", "max"]
        # Float32 or Float64 -> Float64
        IF  "${valueType}" in ["Float32", "Float64"]
            ${expected_valueType}=  Set Variable  Float64
        # Int8, Int16, Int32, Int64 -> Int64
        ELSE IF  "${valueType}" in ["Int8", "Int16", "Int32", "Int64"]
            ${expected_valueType}=  Set Variable  Int64
        # Uint8, Uint16, Uint32, Uint64 -> Uint64
        ELSE IF  "${valueType}" in ["Uint8", "Uint16", "Uint32", "Uint64"]
            ${expected_valueType}=  Set Variable  Uint64
        ELSE
            Fail  Unsupported valueType: ${valueType}
        END
    ELSE
        Fail  Unsupported aggregate function: ${func_type}
    END
    Set Test Variable  ${expected_valueType}

Get Created Values And ValueType For Device And Resource
    [Arguments]  ${deviceName}  ${resourceName}
    @{created_values}=  Create List
    ${valueType}=  Set Variable  ${EMPTY}
    FOR  ${reading}  IN  @{test_readings}
        IF  "${reading}[deviceName]" == "${deviceName}" and "${reading}[resourceName]" == "${resourceName}"
            ${numeric_value}=  Convert To Number  ${reading}[value]
            Append To List  ${created_values}  ${numeric_value}
            IF  "${valueType}" == "${EMPTY}"
                ${valueType}=  Set Variable  ${reading}[valueType]
            END
        END
    END
    Set Test Variable  ${created_values}
    Set Test Variable  ${created_valueType}  ${valueType}


Each Resource for Devices Should Return Only One Reading With Func as Numeric Value
    [Arguments]  ${expected_devices}  ${expected_resources}
    Should Be Equal  ${content}[aggregateFunc]  ${func_type}

    FOR  ${reading}  IN  @{content}[readings]
      Should Contain  ${expected_devices}  ${reading}[deviceName]
      Should Contain  ${expected_resources}  ${reading}[resourceName]

      Get Created Values And ValueType For Device And Resource  ${reading}[deviceName]  ${reading}[resourceName]
      Return Value Should As Numeric And Match Function  ${reading}[value]  ${created_values}
      Get Expected Aggregate ValueType  ${created_valueType}
      Should Be Equal  ${reading}[valueType]  ${expected_valueType}
    END

Each Device for Resource ${expected_resource} Should Return Only One Reading With Func as Numeric Value
    [Arguments]  ${expected_devices}
    Should Be Equal  ${content}[aggregateFunc]  ${func_type}
    ${expected_readings_count}=  Get Length  ${expected_devices}
    ${actual_readings_count}=  Get Length  ${content}[readings]
    Should Be Equal  ${actual_readings_count}  ${expected_readings_count}
    FOR  ${index}  IN RANGE  ${expected_readings_count}
        ${reading}=  Get From List  ${content}[readings]  ${index}
        Should Be Equal  ${reading}[deviceName]  ${expected_devices}[${index}]
        Should Be Equal  ${reading}[resourceName]  ${expected_resource}

        Get Created Values And ValueType For Device And Resource  ${expected_devices}[${index}]  ${expected_resource}
        Return Value Should As Numeric And Match Function  ${reading}[value]  ${created_values}
        Get Expected Aggregate ValueType  ${created_valueType}
        Should Be Equal  ${reading}[valueType]  ${expected_valueType}
    END

Return value should as Numeric and match Function
    [Arguments]  ${actual_value}  ${test_values}
    Should Be True  isinstance(${actual_value}, (int, float))
    IF  "${func_type}" == "min"
        ${expected_value}=  Evaluate  min(${test_values})
    ELSE IF  "${func_type}" == "max"
        ${expected_value}=  Evaluate  max(${test_values})
    ELSE IF  "${func_type}" == "count"
        ${expected_value}=  Get Length  ${test_values}
    ELSE IF  "${func_type}" == "sum"
        ${expected_value}=  Evaluate  sum(${test_values})
    ELSE IF  "${func_type}" == "avg"
        ${expected_value}=  Evaluate  sum(${test_values}) / len(${test_values})
    END
    Should Be Equal As Numbers  ${actual_value}  ${expected_value}

Returned Readings Count Should Be ${expected_count}
    ${actual_readings_count}=  Get Length  ${content}[readings]
    Should Be Equal  '${actual_readings_count}'  '${expected_count}'
