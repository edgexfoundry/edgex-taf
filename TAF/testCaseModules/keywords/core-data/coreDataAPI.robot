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
${coreDataEventUri}    /api/${API_VERSION}/event
${coreDataReadingUri}  /api/${API_VERSION}/reading
${coreDataValueDescriptorUri}  /api/${API_VERSION}/valuedescriptor

*** Keywords ***
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

# Event
Create event with ${deviceName} and ${profileName} and ${sourceName}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Data    ${coreDataEventUri}/${profileName}/${deviceName}/${sourceName}  json=${event}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  log to console  ${content}

Query event by event id "${event_id}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${api}=  Set Variable   ${coreDataEventUri}/id/${event_id}
    ${resp}=  GET On Session  Core Data    ${api}   headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
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

# generate data for core-data
Generate event sample
    # event_data: Event, Event With Tags ; readings_type: Simple Reading, Simple Float Reading, Binary Reading
    [arguments]  ${event_data}  ${deviceName}  ${profileName}  ${sourceName}  @{readings_type}
    ${uuid}=  Evaluate  str(uuid.uuid4())
    ${origin}=  Get current nanoseconds epoch time
    @{readings}=  Create List
    FOR  ${type}  IN  @{readings_type}
        ${reading}=  Load data file "core-data/readings_data.json" and get variable "${type}"
        Set to dictionary  ${reading}  origin=${origin}
        Set to dictionary  ${reading}  deviceName=${deviceName}
        Set to dictionary  ${reading}  profileName=${profileName}
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
    Create Event With Device-Test-001 and Profile-Test-001 and Command-Test-001
    Generate Event Sample  Event  Device-Test-002  Profile-Test-001  Command-Test-002  Simple Reading  Simple Float Reading
    Create Event With Device-Test-002 and Profile-Test-001 and Command-Test-002
  END

Create multiple events twice to get start/end time
  ${start_time}=  Get current nanoseconds epoch time
  Create Multiple Events
  ${end_time}=  Get current nanoseconds epoch time
  Create Multiple Events
  Set Test Variable  ${start_time}  ${start_time}
  Set Test Variable  ${end_time}  ${end_time}
