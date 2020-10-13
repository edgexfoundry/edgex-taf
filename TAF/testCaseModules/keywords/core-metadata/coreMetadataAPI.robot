*** Settings ***
Library   RequestsLibrary
Library   OperatingSystem
Library   Collections
Library   String
Library   yaml
Library   TAF/testCaseModules/keywords/setup/setup_teardown.py
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${coreMetadataUrl}   ${URI_SCHEME}://${BASE_URL}:${CORE_METADATA_PORT}
${api_version}       v1  # default value is v1, set "${api_version}  v2" in testsuite Variables section for v2 api
${deviceProfileUri}  /api/${api_version}/deviceprofile
${deviceUri}         /api/${api_version}/device
${LOG_FILE_PATH}     ${WORK_DIR}/TAF/testArtifacts/logs/coreMetadataAPI.log

*** Keywords ***
# Device Profile
Upload device profile ${file}
    ${yaml}=  Get Binary File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/${file}
    ${files}=  Create Dictionary  file=${yaml}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Metadata  ${deviceProfileUri}/uploadfile  files=${files}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  log to console  ${content}

Create device profile ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Metadata  ${deviceProfileUri}  json=${entity}   headers=${headers}
    Run Keyword If  "${api_version}" == "v1"  Run Keywords
    ...             Run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ...             AND  Set Test Variable  ${response}  ${resp.status_code}
    ...    ELSE IF  "${api_version}" == "v2"  Run Keywords  Set Response to Test Variables  ${resp}
    ...             AND  Run keyword if  ${response} != 207  log to console  ${content}

Query device profile by id and return by device profile name
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=   get request  Core Metadata    ${deviceProfileUri}/${deviceProfileId}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_length}=  get length  ${resp.content}
    run keyword if  ${resp_length} == 3   fail  "No device profile found"
    ${deviceProfileBody}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]    ${deviceProfileBody}[name]

Query device profile by name
    [Arguments]   ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=   get request  Core Metadata    ${deviceProfileUri}/name/${device_profile_name}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_length}=  get length  ${resp.content}
    run keyword if  ${resp_length} == 3   fail  "The device profile ${device_profile_name} is not found"
    run keyword if  ${resp.status_code} == 200  set test variable  ${response}  ${resp.status_code}
    [Return]  ${resp.content}

Delete device profile by name
    [Arguments]   ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  ${deviceProfileUri}/name/${device_profile_name}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Delete multiple device profiles by names
    [Arguments]  @{profile_list}
    FOR  ${profile}  IN  @{profile_list}
        Delete device profile by name  ${profile}
    END

# Device
Create device
    [Arguments]  ${device_file}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${deviceServiceProtocol}=  Load data file "core-metadata/device_protocol.json" and get variable "${SERVICE_NAME}"
    ${protocol_str}=  convert to string  ${deviceServiceProtocol}
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/${device_file}  encoding=UTF-8
    ${newdata_protocol}=  replace string    ${data}   %DeviceServiceProtocal%   ${protocol_str}
    ${newdata_protocol}=  replace string    ${newdata_protocol}   '   \"
    ${newdata}=  replace string  ${newdata_protocol}   %DeviceServiceName%    ${SERVICE_NAME}
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Metadata  ${deviceUri}  data=${newdata}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    set suite variable  ${device_id}   ${resp.content}
    sleep  500ms

Create device with ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Metadata    ${deviceUri}  json=${entity}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

Creat device with autoEvents parameter
    [Arguments]  ${frequency_time}  ${onChange_value}  ${reading_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${deviceServiceProtocol}=  Load data file "core-metadata/device_protocol.json" and get variable "${SERVICE_NAME}"
    ${protocol_str}=  convert to string  ${deviceServiceProtocol}
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/create_autoevent_device.json  encoding=UTF-8
    ${newdata_protocol}=  replace string    ${data}   %DeviceServiceProtocal%   ${protocol_str}
    ${newdata_protocol}=  replace string    ${newdata_protocol}   '   \"
    ${newdata}=  replace string  ${newdata_protocol}   %DeviceServiceName%    ${SERVICE_NAME}
    ${newdata}=  replace string  ${newdata}   %frequency%    ${frequency_time}
    ${newdata}=  replace string  ${newdata}   %onChangeValue%   ${onChange_value}
    ${newdata}=  replace string  ${newdata}   %ReadingName%    ${reading_name}
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Metadata  ${deviceUri}  data=${newdata}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    set test variable  ${device_id}   ${resp.content}

Query device by id and return device name
    # output device name
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata    ${deviceUri}/${device_id}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_length}=    get length  ${resp.content}
    run keyword if  ${resp_length} == 3   fail  "No device found"
    ${deviceResponseBody}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]    ${deviceResponseBody}[name]

Query device by name
    [Arguments]  ${device_name}
    # device detail
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${responseBody}=  Get Request  Core Metadata    ${deviceUri}/name/${device_name}  headers=${headers}
    [Return]    ${responseBody}


Delete device by name
    ${deviceName}=    Query device by id and return device name
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  ${deviceUri}/name/${deviceName}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

Delete device by name ${deviceName}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  ${deviceUri}/name/${deviceName}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# Addressable
Create addressable ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Metadata    /api/v1/addressable  json=${entity}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

Delete addressable by name ${addressableName}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  api/v1/addressable/name/${addressableName}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# Device service
Create device service ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Metadata  /api/${api_version}/deviceservice  json=${entity}   headers=${headers}
    Run Keyword If  "${api_version}" == "v1"  Run Keywords
    ...             Run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ...             AND  Set Test Variable  ${response}  ${resp.status_code}
    ...    ELSE IF  "${api_version}" == "v2"  Run Keywords  Set Response to Test Variables  ${resp}
    ...             AND  Run keyword if  ${response} != 207  log to console  ${content}

Delete device service by name
    [Arguments]   ${deviceServiceName}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  api/${api_version}/deviceservice/name/${deviceServiceName}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Delete multiple device servics by names
    [Arguments]  @{service_list}
    FOR  ${service}  IN  @{service_list}
        Delete device service by name  ${service}
    END

# generate data for core-metadata
Generate Device Profiles
    [Arguments]  @{data_list}
    ${profile_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  profile=${data}
        Append To List  ${profile_list}  ${json}
    END
    Set Test Variable  ${deviceProfile}  ${profile_list}

Generate Multiple Device Profiles Sample
    ${profile_1}=  Load yaml file "core-metadata/deviceprofile/Test-Profile-1.yaml" and convert to dictionary
    ${profile_2}=  Load yaml file "core-metadata/deviceprofile/Test-Profile-2.yaml" and convert to dictionary
    ${profile_3}=  Load yaml file "core-metadata/deviceprofile/Test-Profile-3.yaml" and convert to dictionary
    Generate Device Profiles  ${profile_1}  ${profile_2}  ${profile_3}

Generate Device Services
    [Arguments]  @{data_list}
    ${service_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  service=${data}
        Append To List  ${service_list}  ${json}
    END
    Set Test Variable  ${deviceService}  ${service_list}

Generate Multiple Device Services Sample
    ${index}=  Get current milliseconds epoch time
    Set Test Variable  ${index}
    ${service_names}=  Create List  Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/deviceservice_data.json  encoding=UTF-8
    ${dict}=  Evaluate  json.loads('''${data}''')  json
    ${data_list}=  Create List
    FOR  ${name}  IN  @{service_names}
        ${service}=  Copy Dictionary  ${dict}
        Set To Dictionary  ${service}  name=${name}
        Append To List  ${data_list}  ${service}
    END
    Generate Device Services  @{data_list}
