*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  TAF.utils.src.setup.setup_teardown

*** Variables ***
${coreMetadataUrl}  http://${BASE_URL}:${CORE_METADATA_PORT}
${deviceProfileUri}    /api/v1/deviceprofile
${deviceUri}    /api/v1/device
${LOG_FILE_PATH}     ${WORK_DIR}/TAF/testArtifacts/logs/coreMetadataAPI.log

*** Keywords ***
# Device Profile
Create device profile
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${file_data}=  Get Binary File  ${WORK_DIR}/TAF/config/${PROFILE}/sample_profile.yaml
    ${files}=  Create Dictionary  file=${file_data}
    ${resp}=  Post Request  Core Metadata  ${deviceProfileUri}/uploadfile  files=${files}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    #set environment variable  deviceProfileId   ${resp.content}
    set suite variable  ${deviceProfileId}  ${resp.content}

Query device profile by id and return by device profile name
    #${deviceProfileId}=  get environment variable  deviceProfileId
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=   get request  Core Metadata    ${deviceProfileUri}/${deviceProfileId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_length}=  get length  ${resp.content}
    run keyword if  ${resp_length} == 3   log to console  "No device profile found"
    run keyword if  ${resp_length} == 3   fatal error
    ${deviceProfileBody}=  evaluate  json.loads('''${resp.content}''')  json
    #${deviceProfileName}=  get  ${deviceProfileBody}[name]
    [Return]    ${deviceProfileBody}[name]

Delete device profile by name
    ${deviceProfileName}=   Query device profile by id and return by device profile name
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Delete Request  Core Metadata  ${deviceProfileUri}/name/${deviceProfileName}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# Device
Create device
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${data}=  Get Binary File  ${WORK_DIR}/TAF/config/${PROFILE}/device.json
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Core Metadata  ${deviceUri}  data=${data}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    set environment variable  deviceId   ${resp.content}

Query device by id and return device name
    # output device name
    ${deviceId}=  get environment variable  deviceId
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Get Request  Core Metadata    ${deviceUri}/${deviceId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_length}=    get length  ${resp.content}
    run keyword if  ${resp_length} == 3   log to console  "No device found"
    run keyword if  ${resp_length} == 3   fatal error
    ${deviceResponseBody}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]    ${deviceResponseBody}[name]


Delete device by name
    ${deviceName}=    Query device by id and return device name
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Delete Request  Core Metadata  ${deviceUri}/name/${deviceName}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

Delete device profile and device
    Delete device by name
    Delete device profile by name

Create device profile and device
    ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
    Should Be True  ${status}  Failed Demo Suite Setup
    Create device profile
    Create device



