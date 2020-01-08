*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  TAF.utils.src.data.value_checker
Resource  ./coreMetadataAPI.robot
Resource  ./commonKeywords.robot

*** Variables ***
${coreDataUrl}  http://${BASE_URL}:${CORE_DATA_PORT}
${coreDataReadingUri}   /api/v1/reading
${coreDataValueDescriptorUri}   /api/v1/valuedescriptor

*** Keywords ***
Device reading should be sent to Core Data
    [Arguments]     ${data_type}    ${reading_name}    ${set_reading_value}
    ${device_reading_data}=  Query device reading "${reading_name}" by device id
    ${device_reading_json}=    evaluate  json.loads('''${device_reading_data}''')  json
    ${result}=  check value equal  ${data_type}  ${set_reading_value}   ${device_reading_json}[0][value]
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

Device autoEvents with "${reading_name}" send by frequency setting "${frequency_value}"s
    ${sleep_time}=  evaluate  ${frequency_value}+1
    ${start_time}=   Get milliseconds epoch time
    :FOR    ${INDEX}    IN RANGE  1  4
    \  sleep  ${sleep_time}s
    \  ${end_time}=   Get milliseconds epoch time
    \  ${device_reading_data}=  run keyword and continue on failure  Query device reading by start/end time  ${start_time}   ${end_time}
    \  @{device_reading_data}=  evaluate  json.loads('''${device_reading_data}''')  json
    \  ${device_reading_count}=  get length  ${device_reading_data}
    \  run keyword and continue on failure  should be equal as integers  ${INDEX}  ${device_reading_count}

Query value descriptor for name "${value_descriptor_name}"
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataValueDescriptorUri}/name/${value_descriptor_name}
    run keyword if  ${resp.status_code}!=200  fail  "Incorrect status code"
    run keyword if  ${resp.status_code}==200  log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
