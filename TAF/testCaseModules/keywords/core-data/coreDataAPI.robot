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
Device reading should be sent to Core Data
    [Arguments]     ${data_type}    ${reading_name}    ${set_reading_value}
    ${device_name}=  Query device by id and return device name
    ${device_reading_data}=  Query device reading by device name "${deviceName}"
    ${result}=  check value equal  ${data_type}  ${set_reading_value}   ${device_reading_data}[0][value]
    should be true  ${result}

Device reading "${validReadingName}" for all device should be sent to Core Data
    Query device reading "${validReadingName}" for all device

Query device reading "${validReadingName}" by device id
    ${device_name}=    Query device by id and return device name
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/name/${validReadingName}/device/${device_name}/1
              ...  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    ${get_reading_result_length}=  get length  ${resp.content}
    run keyword if  ${get_reading_result_length} <=3    fail  "No device reading found"
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp.content}

Query device reading by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/${start_time}/${end_time}/10  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    ${get_reading_result_length}=  get length  ${resp.content}
    run keyword if  ${get_reading_result_length} <=3    fail  "No device reading found"
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]   ${resp.content}

Query device reading "${validReadingName}" for all device
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ${get_reading_result_length}=  get length  ${resp.content}
    run keyword if  ${get_reading_result_length} >=3    fail  "No device reading found"
    Should Be Equal As Strings  ${resp.status_code}  200
    log  ${resp.content}

Query device reading by device name "${deviceName}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/device/${deviceName}/100  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ${get_reading_result_length}=  get length  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${readings}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]   ${readings}

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

Query value descriptor for name "${value_descriptor_name}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataValueDescriptorUri}/name/${value_descriptor_name}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    run keyword if  ${resp.status_code}==200  log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

Query readings by value descriptor ${valueDescriptor} and device id "${deviceId}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/name/${valueDescriptor}/device/${deviceId}/100
              ...  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    Should Be Equal As Strings  ${resp.status_code}  200
    @{readings}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]   @{readings}

Add reading with value ${value} by value descriptor ${valueDescriptor} and device id ${deviceId}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${data}=    Create Dictionary   device=${deviceId}   name=${valueDescriptor}    value=${value}
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Data    ${coreDataReadingUri}  json=${data}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

## Event API
Query event by event id "${event_id}"
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${api}=  Set Variable If   "${api_version}"=="v1"  ${coreDataEventUri}/${event_id}
    ...      "${api_version}"=="v2"  ${coreDataEventUri}/id/${event_id}
    ${resp}=  Get Request  Core Data    ${api}   headers=${headers}
    Run Keyword If  "${api_version}"=="v2"  Set Response to Test Variables  ${resp}
    [Return]  ${resp.status_code}  ${resp.content}

Query device event by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataEventUri}/${start_time}/${end_time}/1   headers=${headers}
    [Return]  ${resp.status_code}  ${resp.content}

Remove all events
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Data    ${coreDataEventUri}/removeold/age/0   headers=${headers}

Query events
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataEventUri}   headers=${headers}
    [Return]  ${resp.status_code}  ${resp.content}

Query all events count
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Data    ${coreDataEventUri}/count  headers=${headers}
    Set Response to Test Variables  ${resp}

Create Events
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Data    ${coreDataEventUri}  json=${events}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

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
    [return]  ${event}

Change ${event} readings[${index}] values ${property_dict}
    ${keys}=  Get dictionary keys  ${property_dict}
    FOR  ${key}  IN  @{keys}
        Dictionary should contain key  ${event}[event][readings][${index}]  ${key}  Reading doesn't contain key: ${key}
        Set to dictionary  ${event}[event][readings][${index}]  ${key}=${property_dict}[${key}]
    END

Generate multiple events sample with simple readings
    ${event1}=  Generate event sample  Event  Device-Test-001  Profile-Test-001  Simple Reading
    ${event2}=  Generate event sample  Event  Device-Test-001  Profile-Test-001  Simple Float Reading
    ${event3}=  Generate event sample  Event  Device-Test-001  Profile-Test-001  Simple Reading  Simple Float Reading
    ${event4}=  Generate event sample  Event With Tags  Device-Test-001  Profile-Test-001  Simple Reading  Simple Float Reading
    ${events}=  Create List  ${event1}  ${event2}  ${event3}  ${event4}
    Set test variable  ${events}  ${events}

Generate an event sample with simple readings
    ${event}=  Generate event sample  Event  Device-Test-001  Profile-Test-001  Simple Reading  Simple Float Reading
    ${events}=  Create List  ${event}
    Set test variable  ${events}  ${events}
