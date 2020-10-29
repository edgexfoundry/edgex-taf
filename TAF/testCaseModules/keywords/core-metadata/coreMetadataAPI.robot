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
${deviceServiceUri}  /api/${api_version}/deviceservice
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

Upload file ${file} to update device profile
    ${yaml}=  Get Binary File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/${file}
    ${files}=  Create Dictionary  file=${yaml}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Put Request  Core Metadata  ${deviceProfileUri}/uploadfile  files=${files}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}

Update device profile ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Put Request  Core Metadata  ${deviceProfileUri}  json=${entity}   headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Query all device profiles
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=   Get request  Core Metadata    ${deviceProfileUri}/all  headers=${headers}
    Set Response to Test Variables  ${resp}
    ${resp_length}=  get length  ${resp.content}
    Run keyword if  ${resp_length} == 3   fail  "No device profile found"

Query all device profiles with ${parameter}=${value}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata  ${deviceProfileUri}/all?${parameter}=${value}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query device profile by name
    [Arguments]   ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=   get request  Core Metadata    ${deviceProfileUri}/name/${device_profile_name}  headers=${headers}
    Set Response to Test Variables  ${resp}
    ${resp_length}=  get length  ${resp.content}  #bytes dict: length of empty list ("[]") is 3
    run keyword if  ${response} != 200 or ${resp_length} == 3  fail  "The device profile ${device_profile_name} is not found"
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

Delete device profile by id
    [Arguments]  ${device_profile_id}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  ${deviceProfileUri}/id/${device_profile_id}  headers=${headers}
    Run Keyword If  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

# Device
# v1 only: in functionalTest/device-service/common/ and integrationTest
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
    Run Keyword If  "${api_version}" == "v1"  Run Keywords
    ...             Run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ...             AND  Set Test Variable  ${response}  ${resp.status_code}
    ...    ELSE IF  "${api_version}" == "v2"  Run Keywords  Set Response to Test Variables  ${resp}
    ...             AND  Run keyword if  ${response} != 207  log to console  ${content}

# v1 only: in functionalTest/device-service/common/
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

Update devices ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Patch Request  Core Metadata  ${deviceUri}  json=${entity}   headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

# v1 only: in keywords/core-data and functionTest/device-service/common/
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

Query all devices
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata  ${deviceUri}/all  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all devices with ${parameter}=${value}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata  ${deviceUri}/all?${parameter}=${value}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query device by name
    [Arguments]  ${device_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata    ${deviceUri}/name/${device_name}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail  "The device ${device_name} is not found"

Query all devices by serviceName
    [Arguments]  ${device_service_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata    ${deviceUri}/service/name/${device_service_name}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all devices by ${associated}Name ${associated_name} with ${parameter}=${value}
    # associated: profile or service ; associated_name: profileName or serviceName
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata  ${deviceUri}/${associated}/name/${associated_name}?${parameter}=${value}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Check existence of device by id
    [Arguments]  ${device_id}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata    ${deviceUri}/check/id/${device_id}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

Check existence of device by name
    [Arguments]  ${device_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata    ${deviceUri}/check/name/${device_name}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

# v1 only: in functionalTest/device-service/common/
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
    Set Response to Test Variables  ${resp}

Delete multiple devices by names
    [Arguments]  @{device_list}
    FOR  ${device}  IN  @{device_list}
        Delete device by name ${device}
    END

Delete device by id
    [Arguments]  ${device_id}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  ${deviceUri}/id/${device_id}  headers=${headers}
    Run Keyword If  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

# Addressable
# v1 only: in functionalTest/core-data/UC_readings/add_reading.robot
Create addressable ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Post Request  Core Metadata    /api/v1/addressable  json=${entity}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

# v1 only: in functionalTest/core-data/UC_readings/add_reading.robot
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
    ${resp}=  Post Request  Core Metadata  ${deviceServiceUri}  json=${entity}   headers=${headers}
    Run Keyword If  "${api_version}" == "v1"  Run Keywords
    ...             Run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    ...             AND  Set Test Variable  ${response}  ${resp.status_code}
    ...    ELSE IF  "${api_version}" == "v2"  Run Keywords  Set Response to Test Variables  ${resp}
    ...             AND  Run keyword if  ${response} != 207  log to console  ${content}

Update device service ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  Patch Request  Core Metadata  ${deviceServiceUri}  json=${entity}   headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Query all device services
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata  ${deviceServiceUri}/all  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all device services with ${parameter}=${value}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata  ${deviceServiceUri}/all?${parameter}=${value}  headers=${headers}
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query device service by name
    [Arguments]  ${device_service_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Get Request  Core Metadata  ${deviceServiceUri}/name/${device_service_name}  headers=${headers}
    Set Response to Test Variables  ${resp}
    run keyword if  ${response}!=200  fail  "The device service ${device_service_name} is not found"

Delete device service by name
    [Arguments]  ${device_service_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  ${deviceServiceUri}/name/${device_service_name}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Delete multiple device services by names
    [Arguments]  @{service_list}
    FOR  ${service}  IN  @{service_list}
        Delete device service by name  ${service}
    END

Delete device service by iD
    [Arguments]  ${device_service_id}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  Delete Request  Core Metadata  ${deviceServiceUri}/id/${device_service_id}  headers=${headers}
    Run Keyword If  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

# generate data for core-metadata
# Device Profile
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

Generate a device profile sample
    [Arguments]  ${device_profile_name}  # Test-Profile-1, Test-Profile-2, Test-Profile-3 or Test-Profile-4
    ${profile}=  Load yaml file "core-metadata/deviceprofile/${device_profile_name}.yaml" and convert to dictionary
    Generate Device Profiles  ${profile}

Generate New ${file} With "${dict}" Property "${property}" Value "${value}"
    ${yaml_dict}=  Load yaml file "core-metadata/deviceprofile/${file}" and convert to dictionary
    Run Keyword IF  "${dict}" == "profile"  Set to Dictionary  ${yaml_dict}  ${property}=${value}
    ...    ELSE IF  "${dict}" == "deviceResources-properties"  Set to Dictionary  ${yaml_dict}[deviceResources][0][properties]  ${property}=${value}
    ...    ELSE IF  "${dict}" == "deviceCommands"  Set to Dictionary  ${yaml_dict}[deviceCommands][0]  ${property}=${value}
    ...    ELSE IF  "${dict}" == "coreCommands"  Set to Dictionary  ${yaml_dict}[coreCommands][1]  ${property}=${value}
    ${yaml}=  yaml.Safe Dump  ${yaml_dict}
    Create File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/NEW-${file}  ${yaml}

Delete Profile Files
    [Arguments]  ${file}
    Remove File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/${file}

# Device Service
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
    ${data_list}=  Create List
    FOR  ${name}  IN  @{service_names}
        ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/deviceservice_data.json  encoding=UTF-8
        ${service}=  Evaluate  json.loads('''${data}''')  json
        Set To Dictionary  ${service}  name=${name}
        Append To List  ${data_list}  ${service}
    END
    Generate Device Services  @{data_list}

Generate a device service sample
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/deviceservice_data.json  encoding=UTF-8
    ${service}=  Evaluate  json.loads('''${data}''')  json
    Generate Device Services  ${service}

Generate Multiple Device Services Sample For Updating
    ${labels}=  Create List  device-example  device-update
    ${update_opstate}=  Create Dictionary  name=Device-Service-${index}-1  labels=${labels}
    ${update_adminstate}=  Create Dictionary  name=Device-Service-${index}-2  adminState=LOCKED
    ${update_baseAddr}=  Create Dictionary  name=Device-Service-${index}-3  baseAddress=http://home-device-service:49991
    Generate Device Services  ${update_opstate}  ${update_adminstate}  ${update_baseAddr}

# Device
Generate Devices
    [Arguments]  @{data_list}
    ${device_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  device=${data}
        Append To List  ${device_list}  ${json}
    END
    Set Test Variable  ${Device}  ${device_list}

Create Multiple Profiles/Services And Generate Multiple Devices Sample
    Generate Multiple Device Services Sample
    Create Device Service ${deviceService}
    Generate Multiple Device Profiles Sample
    Create Device Profile ${deviceProfile}
    ${device_1}=  Set device values  Device-Service-${index}-1  Test-Profile-1
    ${device_2}=  Set device values  Device-Service-${index}-2  Test-Profile-2
    Set To Dictionary  ${device_2}  name=Test-Device-Locked
    Set To Dictionary  ${device_2}  adminState=LOCKED
    ${device_3}=  Set device values  Device-Service-${index}-3  Test-Profile-3
    Set To Dictionary  ${device_3}  name=Test-Device-Disabled
    Set To Dictionary  ${device_3}  operatingState=DISABLED
    ${profile}=  Load yaml file "core-metadata/deviceprofile/Test-Profile-1.yaml" and convert to dictionary
    ${autoEvent}=  Set autoEvents values  10s  false  ${profile}[deviceResources][0][name]
    ${autoEvents}=  Create List  ${autoEvent}
    ${device_4}=  Set device values  Device-Service-${index}-1  Test-Profile-1
    Set To Dictionary  ${device_4}  name=Test-Device-AutoEvents
    Set To Dictionary  ${device_4}  autoEvents=${autoEvents}
    Generate Devices  ${device_1}  ${device_2}  ${device_3}  ${device_4}

Create A Device Sample With Associated Test-Device-Service And ${device_profile_name}
    Generate A Device Service Sample
    Create Device Service ${deviceService}
    Get "id" From Multi-status Item 0
    Set Test Variable  ${device_service_id}  ${item_value}
    Generate A Device Profile Sample  ${device_profile_name}
    Create Device Profile ${deviceProfile}
    Get "id" From Multi-status Item 0
    Set Test Variable  ${device_profile_id}  ${item_value}
    ${device}=  Set device values  Test-Device-Service  ${device_profile_name}
    Generate Devices  ${device}
    Create Device With ${Device}

Set device values
    [Arguments]  ${device_service_name}  ${device_profile_name}
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/V2-device/device_data.json  encoding=UTF-8
    ${device}=  Evaluate  json.loads('''${data}''')  json
    ${protocols}=  Load data file "core-metadata/device_protocol.json" and get variable "${SERVICE_NAME}"
    Set To Dictionary  ${device}  protocols=${protocols}
    Set To Dictionary  ${device}  serviceName=${device_service_name}
    Set To Dictionary  ${device}  profileName=${device_profile_name}
    [Return]  ${device}

Set autoEvents values
    [Arguments]  ${frequency}  ${onChange}  ${resource}
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/V2-device/auto_events_data.json  encoding=UTF-8
    ${autoEvent}=  Evaluate  json.loads('''${data}''')  json
    Set To Dictionary  ${autoEvent}  frequency=${frequency}
    ${onChange}=  Convert To Boolean  ${onChange}
    Set To Dictionary  ${autoEvent}  onChange=${onChange}
    Set To Dictionary  ${autoEvent}  resource=${resource}
    [Return]  ${autoEvent}

Create Devices And Generate Multiple Devices Sample For Updating ${type}
    Create Multiple Profiles/Services And Generate Multiple Devices Sample
    Create Device With ${Device}
    ${labels}=  Create List  device-example  device-update
    ${update_labels}=  Create Dictionary  name=Test-Device  labels=${labels}
    ${update_adminstate}=  Create Dictionary  name=Test-Device-Locked  adminState=UNLOCKED
    ${update_opstate}=  Create Dictionary  name=Test-Device-Disabled  operatingState=ENABLED
    ${protocols}=  Load data file "core-metadata/device_protocol.json" and get variable "device-virtual"
    Set To Dictionary  ${protocols}[other]  Address=simple02
    ${update_protocols}=  Create Dictionary  name=Test-Device-AutoEvents  protocols=${protocols}
    Run Keyword If  "${type}" != "Data"  run keywords  Set To Dictionary  ${update_adminstate}  adminState=LOCKED
    ...        AND  Set To Dictionary  ${update_adminstate}  serviceName=Device-Service-${index}-3
    Run Keyword If  "${type}" != "Data"  run keywords  Set To Dictionary  ${update_opstate}  operatingState=DISABLED
    ...        AND  Set To Dictionary  ${update_opstate}  profileName=Test-Profile-3
    Generate Devices  ${update_labels}  ${update_adminstate}  ${update_opstate}  ${update_protocols}

Delete Multiple Devices Sample, Profiles Sample And Services Sample
    Delete Multiple Devices By Names
    ...  Test-Device  Test-Device-Locked  Test-Device-Disabled  Test-Device-AutoEvents
    Delete multiple device services by names
    ...  Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    Delete multiple device profiles by names
    ...  Test-Profile-1  Test-Profile-2  Test-Profile-3

