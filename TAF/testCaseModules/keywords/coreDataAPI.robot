*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  TAF.utils.src.data.value_checker
Resource  ./coreMetadataAPI.robot
Resource  ./commonKeywords.robot

*** Variables ***
${coreDataUrl}  http://${BASE_URL}:${CORE_DATA_PORT}
${coreDataEventUri}     /api/v1/event
${coreDataReadingUri}   /api/v1/reading
${coreDataValueDescriptorUri}   /api/v1/valuedescriptor

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
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/name/${validReadingName}/device/${device_name}/1
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    ${get_reading_result_length}=  get length  ${resp.content}
    run keyword if  ${get_reading_result_length} <=3    fail  "No device reading found"
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp.content}

Query device reading by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/${start_time}/${end_time}/10
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    ${get_reading_result_length}=  get length  ${resp.content}
    run keyword if  ${get_reading_result_length} <=3    fail  "No device reading found"
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]   ${resp.content}

Query device reading "${validReadingName}" for all device
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ${get_reading_result_length}=  get length  ${resp.content}
    run keyword if  ${get_reading_result_length} >=3    fail  "No device reading found"
    Should Be Equal As Strings  ${resp.status_code}  200
    log  ${resp.content}

Query device reading by device name "${deviceName}"
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/device/${deviceName}/100
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
    :FOR    ${INDEX}    IN RANGE  1  4
    \  sleep  ${sleep_time}s
    \  ${end_time}=   Get current milliseconds epoch time
    \  ${expected_device_reading_count}=  evaluate  ${init_device_reading_count} + ${INDEX}
    \  ${device_reading_data}=  run keyword and continue on failure  Query device reading by device name "AutoEvent-Device"
    \  ${device_reading_count}=  get length  ${device_reading_data}
    \  run keyword and continue on failure  should be equal as integers  ${expected_device_reading_count}  ${device_reading_count}

Query value descriptor for name "${value_descriptor_name}"
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataValueDescriptorUri}/name/${value_descriptor_name}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    run keyword if  ${resp.status_code}==200  log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

Query readings by value descriptor ${valueDescriptor} and device id "${deviceId}"
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/name/${valueDescriptor}/device/${deviceId}/100
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    Should Be Equal As Strings  ${resp.status_code}  200
    @{readings}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]   @{readings}

Add reading with value ${value} by value descriptor ${valueDescriptor} and device id ${deviceId}
    Create Session  Core Data  url=${coreDataUrl}
    ${data}=    Create Dictionary   device=${deviceId}   name=${valueDescriptor}    value=${value}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Core Data    ${coreDataReadingUri}  json=${data}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

## Event API
Query event by event id "${event_id}"
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataEventUri}/${event_id}
    [Return]  ${resp.status_code}  ${resp.content}

Query device event by start/end time
    [Arguments]  ${start_time}   ${end_time}
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataEventUri}/${start_time}/${end_time}/1
    [Return]  ${resp.status_code}  ${resp.content}

Remove all events
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Delete Request  Core Data    ${coreDataEventUri}/removeold/age/0

