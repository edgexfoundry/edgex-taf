*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Resource  ./coreMetadataAPI.robot

*** Variables ***
${coreDataUrl}  http://${BASE_URL}:${CORE_DATA_PORT}
${coreDataReadingUri}   /api/v1/reading


*** Keywords ***
Device reading "${validReadingName}" should be sent to Core Data
    Query device reading "${validReadingName}" by device id


Query device reading "${validReadingName}" by device id
    ${deviceName}=    Query device by id and return device name
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/name/${validReadingName}/device/${deviceName}/5
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    run keyword if  ${resp.status_code}!=200  log to console  "No device reading found"
    Should Be Equal As Strings  ${resp.status_code}  200
    log  ${resp.content}

Query device reading for all device
    ${deviceId}=    get environment variable  deviceId
    Create Session  Core Data  url=${coreDataUrl}
    ${resp}=  Get Request  Core Data    ${coreDataReadingUri}/device/${deviceId}/5
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    log  ${resp.content}


