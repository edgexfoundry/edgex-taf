*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  Collections
Library  uuid
Library  TAF/testCaseModules/keywords/common/value_checker.py
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${coreDataUrl}  ${URI_SCHEME}://${BASE_URL}:${CORE_DATA_PORT}
${api_version}  v1  # default value is v1, set "${api_version}  v2" in testsuite Variables section for v2 api
${coreDataEventUri}    /api/${api_version}/event
${coreDataReadingUri}  /api/${api_version}/reading
${coreDataValueDescriptorUri}  /api/${api_version}/valuedescriptor

*** Keywords ***
# v1 only: in integrationTest
Device reading should be sent to Core Data
    [Arguments]     ${data_type}    ${reading_name}    ${set_reading_value}
    ${device_name}=  Query device by id and return device name
    ${device_reading_data}=  Query device reading by device name "${deviceName}"
    ${result}=  check value equal  ${data_type}  ${set_reading_value}   ${device_reading_data}[0][value]
    should be true  ${result}

Query all readings
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataReadingUri}/all  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query all readings with ${parameter}=${value}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataReadingUri}/all  params=${parameter}=${value}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query readings by resourceName
    [Arguments]  ${resource_name}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataReadingUri}/resourceName/${resource_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query readings by device name
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataReadingUri}/device/name/${device_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query readings by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataReadingUri}/start/${start_time}/end/${end_time}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Query all readings count
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataReadingUri}/count  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query readings count by device name
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataReadingUri}/count/device/name/${device_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

# v1 only: in functionTest/device-service/common/
Query device reading by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataReadingUri}/${start_time}/${end_time}/10  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  fail  ${resp.status_code}!=200: ${resp.content}
    ${get_reading_result_length}=  get length  ${resp.content}
    run keyword if  ${get_reading_result_length} <=3    fail  "No device reading found"
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]   ${resp.content}

# v1 only: in keywords/core-data
Query device reading by device name "${deviceName}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataReadingUri}/device/${deviceName}/100  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ${get_reading_result_length}=  get length  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${readings}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]   ${readings}

# v1 only: in functionTest/device-service/common/
Device autoEvents with "${reading_name}" send by frequency setting "${frequency_value}"s
    ${sleep_time}=  evaluate  ${frequency_value}
    ${start_time}=   Get current milliseconds epoch time
    # Sleep 2 seconds for first auto event of C DS because it will execute auto event after creating the device without schedule time
    sleep  2
    ${init_device_reading_data}=  run keyword and continue on failure  Query device reading by device name "AutoEvent-Device"
    ${init_device_reading_count}=  get length  ${init_device_reading_data}
    FOR    ${INDEX}    IN RANGE  1  4
       sleep  ${sleep_time}s
       ${end_time}=   Get current milliseconds epoch time
       ${expected_device_reading_count}=  evaluate  ${init_device_reading_count} + ${INDEX}
       ${device_reading_data}=  run keyword and continue on failure  Query device reading by device name "AutoEvent-Device"
       ${device_reading_count}=  get length  ${device_reading_data}
       run keyword and continue on failure  should be equal as integers  ${expected_device_reading_count}  ${device_reading_count}
    END

# v1 only: in keywords/core-data
Query value descriptor for name "${value_descriptor_name}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataValueDescriptorUri}/name/${value_descriptor_name}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  fail  ${resp.status_code}!=200: ${resp.content}
    log   ${resp.content}

# v1 only: in keywords/core-data
Query readings by value descriptor ${valueDescriptor} and device id "${deviceId}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataReadingUri}/name/${valueDescriptor}/device/${deviceId}/100
    ...       headers=${headers}  expected_status=any
    run keyword if  ${resp.status_code}!=200  fail  ${resp.status_code}!=200: ${resp.content}

    @{readings}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]   @{readings}

# v1 only: in functionalTest/core-data
Add reading with value ${value} by value descriptor ${valueDescriptor} and device id ${deviceId}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${data}=    Create Dictionary   device=${deviceId}   name=${valueDescriptor}    value=${value}
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Data  ${coreDataReadingUri}  json=${data}  headers=${headers}  expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

# Event
Create event with ${deviceName} and ${profileName}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Data    ${coreDataEventUri}/${profileName}/${deviceName}  json=${event}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  log to console  ${content}

Query event by event id "${event_id}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${api}=  Set Variable If   "${api_version}"=="v1"  ${coreDataEventUri}/${event_id}
    ...      "${api_version}"=="v2"  ${coreDataEventUri}/id/${event_id}
    ${resp}=  GET On Session  Core Data    ${api}   headers=${headers}  expected_status=any
    Run Keyword If  "${api_version}"=="v2"  Set Response to Test Variables  ${resp}
    [Return]  ${resp.status_code}  ${resp.content}

# v1 only: in integrationTest
Query events
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataEventUri}   headers=${headers}  expected_status=any
    [Return]  ${resp.status_code}  ${resp.content}

Query all events
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataEventUri}/all   headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query events by device name
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataEventUri}/device/name/${device_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query events by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataEventUri}/start/${start_time}/end/${end_time}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Query all events count
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataEventUri}/count  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query events count by device name
    [Arguments]  ${device_name}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data    ${coreDataEventUri}/count/device/name/${device_name}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Delete all events by age
    [Arguments]  ${age}=0
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Data  ${coreDataEventUri}/age/${age}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=202  fail  ${response}!=202: ${content}

Delete event by id
    [Arguments]  ${id}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Data  ${coreDataEventUri}/id/${id}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=200  fail  ${response}!=200: ${content}

Delete events by device name
    [Arguments]  ${deviceName}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Data  ${coreDataEventUri}/device/name/${deviceName}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run Keyword If  ${response}!=202  fail  ${response}!=202: ${content}

# v1 only: in integrationTest
Remove all events
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Data  ${coreDataEventUri}/removeold/age/0  headers=${headers}
    ...       expected_status=200

# generate data for core-data
Generate event sample
    # event_data: Event, Event With Tags ; readings_type: Simple Reading, Simple Float Reading, Binary Reading
    [arguments]  ${event_data}  ${deviceName}  ${profileName}  @{readings_type}
    ${uuid}=  Evaluate  str(uuid.uuid4())
    ${millisec_epoch_time}=  Get current milliseconds epoch time
    ${origin}=  Evaluate  int(${millisec_epoch_time}*1000000)
    @{readings}=  Create List
    FOR  ${type}  IN  @{readings_type}
        ${reading}=  Load data file "core-data/readings_data.json" and get variable "${type}"
        Set to dictionary  ${reading}  origin=${origin}
        Set to dictionary  ${reading}  deviceName=${deviceName}
        Set to dictionary  ${reading}  profileName=${profileName}
        Append to List  ${readings}  ${reading}
    END
    ${event}=  Load data file "core-data/event_data.json" and get variable "${event_data}"
    Set to dictionary  ${event}[event]  deviceName=${deviceName}
    Set to dictionary  ${event}[event]  profileName=${profileName}
    Set to dictionary  ${event}[event]  id=${uuid}
    Set to dictionary  ${event}[event]  origin=${origin}
    Set to dictionary  ${event}[event]  readings=${readings}
    Set test variable  ${id}  ${uuid}
    Set test variable  ${event}  ${event}

Create multiple events
  FOR  ${index}  IN RANGE  0  3   # total: 6 events, 9 readings
    Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Simple Reading
    Create Event With Device-Test-001 and Profile-Test-001
    Generate Event Sample  Event  Device-Test-002  Profile-Test-001  Simple Reading  Simple Float Reading
    Create Event With Device-Test-002 and Profile-Test-001
  END

Create multiple events twice to get start/end time
  ${start_time}=  Get current milliseconds epoch time
  Create Multiple Events
  ${end_time}=  Get current milliseconds epoch time
  Create Multiple Events
  Set Test Variable  ${start_time}  ${start_time}
  Set Test Variable  ${end_time}  ${end_time}
