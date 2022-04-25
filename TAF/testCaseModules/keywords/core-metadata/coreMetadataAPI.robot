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
${deviceProfileUri}  /api/${API_VERSION}/deviceprofile
${deviceServiceUri}  /api/${API_VERSION}/deviceservice
${deviceResourceUri}  /api/${API_VERSION}/deviceresource
${deviceUri}         /api/${API_VERSION}/device
${provisionWatcherUri}  /api/${API_VERSION}/provisionwatcher
${LOG_FILE_PATH}     ${WORK_DIR}/TAF/testArtifacts/logs/coreMetadataAPI.log

*** Keywords ***
# Device Profile
Upload device profile ${file}
    ${yaml}=  Get Binary File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/${file}
    ${files}=  Create Dictionary  file=${yaml}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Metadata  ${deviceProfileUri}/uploadfile  files=${files}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  log to console  ${content}

Create device profile ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Metadata  ${deviceProfileUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Upload file ${file} to update device profile
    ${yaml}=  Get Binary File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/${file}
    ${files}=  Create Dictionary  file=${yaml}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  PUT On Session  Core Metadata  ${deviceProfileUri}/uploadfile  files=${files}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}

Update device profile ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  PUT On Session  Core Metadata  ${deviceProfileUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Query all device profiles
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata    ${deviceProfileUri}/all  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    ${resp_length}=  get length  ${resp.content}
    Run keyword if  ${resp_length} == 3   fail  "No device profile found"

Query all device profiles with ${parameter}=${value}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceProfileUri}/all  params=${parameter}=${value}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all device profiles by manufacturer
    [Arguments]  ${manufacturer}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceProfileUri}/manufacturer/${manufacturer}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all device profiles by model
    [Arguments]  ${model}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceProfileUri}/model/${model}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all device profiles by ${device_info} ${info_value} with ${parameter}=${value}
    # device_info: manufacturer or model ; info_value: the value of manfacturer or model
    ${device_info}=  Convert To Lower Case  ${device_info}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceProfileUri}/${device_info}/${info_value}
    ...       params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all device profiles by manufacturer and model
    [Arguments]  ${manufacturer}  ${model}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceProfileUri}/manufacturer/${manufacturer}/model/${model}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all device profiles having manufacturer ${manufacturer} and model ${model} with ${parameter}=${value}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceProfileUri}/manufacturer/${manufacturer}/model/${model}
    ...       params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query device profile by name
    [Arguments]   ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata    ${deviceProfileUri}/name/${device_profile_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    ${resp_length}=  get length  ${resp.content}  #bytes dict: length of empty list ("[]") is 3
    run keyword if  ${response} != 200 or ${resp_length} == 3  fail  "The device profile ${device_profile_name} is not found"
    [Return]  ${resp.content}

Query device resource by resourceName and profileName
    [Arguments]   ${resource_name}  ${profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceResourceUri}/profile/${profile_name}/resource/${resource_name}
    ...       headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Delete device profile by name
    [Arguments]   ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Metadata  ${deviceProfileUri}/name/${device_profile_name}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Delete multiple device profiles by names
    [Arguments]  @{profile_list}
    FOR  ${profile}  IN  @{profile_list}
        Delete device profile by name  ${profile}
    END

# Device
Create device with ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Metadata    ${deviceUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Update devices ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  PATCH ON Session  Core Metadata  ${deviceUri}  json=${entity}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Query all devices
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceUri}/all  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query all devices with ${parameter}=${value}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceUri}/all  params=${parameter}=${value}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query device by name
    [Arguments]  ${device_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceUri}/name/${device_name}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail  "The device ${device_name} is not found"

Query all devices by serviceName
    [Arguments]  ${device_service_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata    ${deviceUri}/service/name/${device_service_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all devices by profileName
    [Arguments]  ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata    ${deviceUri}/profile/name/${device_profile_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query all devices by ${associated}Name ${associated_name} with ${parameter}=${value}
    # associated: profile or service ; associated_name: profileName or serviceName
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceUri}/${associated}/name/${associated_name}
    ...       params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Check existence of device by name
    [Arguments]  ${device_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata    ${deviceUri}/check/name/${device_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

Delete device by name ${deviceName}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Metadata  ${deviceUri}/name/${deviceName}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Delete multiple devices by names
    [Arguments]  @{device_list}
    FOR  ${device}  IN  @{device_list}
        Delete device by name ${device}
    END

# Device service
Create device service ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Metadata  ${deviceServiceUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Update device service ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  PATCH ON Session  Core Metadata  ${deviceServiceUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Query all device services
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceServiceUri}/all  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query all device services with ${parameter}=${value}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceServiceUri}/all  params=${parameter}=${value}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query device service by name
    [Arguments]  ${device_service_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${deviceServiceUri}/name/${device_service_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    run keyword if  ${response}!=200  fail  "The device service ${device_service_name} is not found"

Delete device service by name
    [Arguments]  ${device_service_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Metadata  ${deviceServiceUri}/name/${device_service_name}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Delete multiple device services by names
    [Arguments]  @{service_list}
    FOR  ${service}  IN  @{service_list}
        Delete device service by name  ${service}
    END

# Provision Watcher
Create provision watcher ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Core Metadata    ${provisionWatcherUri}  json=${entity}   headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Delete provision watcher by name ${provisionWatcherName}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  DELETE On Session  Core Metadata  ${provisionWatcherUri}/name/${provisionWatcherName}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set Response to Test Variables  ${resp}

Delete multiple provision watchers by names
    [Arguments]  @{provisionWatcher_list}
    FOR  ${provisionWatcher}  IN  @{provisionWatcher_list}
        Delete provision watcher by name ${provisionWatcher}
    END

Update Provision Watchers ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  PATCH ON Session  Core Metadata  ${provisionWatcherUri}  json=${entity}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 207  log to console  ${content}

Query Provision Watchers By Name
    [Arguments]  ${provision_watcher_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${provisionWatcherUri}/name/${provision_watcher_name}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail  "The provision watcher ${provision_watcher_name} is not found"

Query All Provision Watchers by ${associated}Name ${associated_name} with ${parameter}=${value}
    # associated: profile or service ; associated_name: profileName or serviceName
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${provisionWatcherUri}/${associated}/name/${associated_name}
    ...       params=${parameter}=${value}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query All Provision Watchers
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${provisionWatcherUri}/all  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query All Provision Watchers with ${parameter}=${value}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata  ${provisionWatcherUri}/all  params=${parameter}=${value}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query All Provision Watchers By profileName
    [Arguments]  ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata    ${provisionWatcherUri}/profile/name/${device_profile_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query All Provision Watchers By serviceName
    [Arguments]  ${device_service_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Metadata    ${provisionWatcherUri}/service/name/${device_service_name}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

# generate data for core-metadata
# Device Profile
Generate Device Profiles
    [Arguments]  @{data_list}
    ${profile_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  profile=${data}
        Set to dictionary  ${json}       apiVersion=${API_VERSION}
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
    ...    ELSE IF  "${dict}" == "deviceCommands-resourceOperations"  Set to Dictionary  ${yaml_dict}[deviceCommands][0][resourceOperations][0]  ${property}=${value}
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
        Set to dictionary  ${json}       apiVersion=${API_VERSION}
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
    ${update_baseAddr}=  Create Dictionary  name=Device-Service-${index}-3  baseAddress=http://home-device-service:59901
    Generate Device Services  ${update_opstate}  ${update_adminstate}  ${update_baseAddr}

# Device
Generate Devices
    [Arguments]  @{data_list}
    ${device_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  device=${data}
        Set to dictionary  ${json}       apiVersion=${API_VERSION}
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
    Set To Dictionary  ${device_3}  operatingState=DOWN
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
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/device_data.json  encoding=UTF-8
    ${device}=  Evaluate  json.loads('''${data}''')  json
    ${protocols}=  Load data file "core-metadata/device_protocol.json" and get variable "${SERVICE_NAME}"
    Set To Dictionary  ${device}  protocols=${protocols}
    Set To Dictionary  ${device}  serviceName=${device_service_name}
    Set To Dictionary  ${device}  profileName=${device_profile_name}
    [Return]  ${device}

Set autoEvents values
    [Arguments]  ${interval}  ${onChange}  ${sourceName}
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/auto_events_data.json  encoding=UTF-8
    ${autoEvent}=  Evaluate  json.loads('''${data}''')  json
    Set To Dictionary  ${autoEvent}  interval=${interval}
    ${onChange}=  Convert To Boolean  ${onChange}
    Set To Dictionary  ${autoEvent}  onChange=${onChange}
    Set To Dictionary  ${autoEvent}  sourceName=${sourceName}
    [Return]  ${autoEvent}

Create Devices And Generate Multiple Devices Sample For Updating ${type}
    Create Multiple Profiles/Services And Generate Multiple Devices Sample
    Create Device With ${Device}
    ${labels}=  Create List  device-example  device-update
    ${update_labels}=  Create Dictionary  name=Test-Device  labels=${labels}
    ${update_adminstate}=  Create Dictionary  name=Test-Device-Locked  adminState=UNLOCKED
    ${update_opstate}=  Create Dictionary  name=Test-Device-Disabled  operatingState=UP
    ${protocols}=  Load data file "core-metadata/device_protocol.json" and get variable "device-virtual"
    Set To Dictionary  ${protocols}[other]  Address=simple02
    ${update_protocols}=  Create Dictionary  name=Test-Device-AutoEvents  protocols=${protocols}
    Run Keyword If  "${type}" != "Data"  run keywords  Set To Dictionary  ${update_adminstate}  adminState=LOCKED
    ...        AND  Set To Dictionary  ${update_adminstate}  serviceName=Device-Service-${index}-3
    ...        AND  Set To Dictionary  ${update_opstate}  operatingState=DOWN
    ...        AND  Set To Dictionary  ${update_opstate}  profileName=Test-Profile-3
    Generate Devices  ${update_labels}  ${update_adminstate}  ${update_opstate}  ${update_protocols}

Delete Multiple Devices Sample, Profiles Sample And Services Sample
    Delete Multiple Devices By Names
    ...  Test-Device  Test-Device-Locked  Test-Device-Disabled  Test-Device-AutoEvents
    Delete multiple device services by names
    ...  Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    Delete multiple device profiles by names
    ...  Test-Profile-1  Test-Profile-2  Test-Profile-3

# Provision Watcher Sample
Generate Provision Watchers
    [Arguments]  @{data_list}
    ${provisionwatcher_list}=  Create List
    FOR  ${data}  IN  @{data_list}
        ${json}=  Create Dictionary  provisionwatcher=${data}
        Set to dictionary  ${json}       apiVersion=${API_VERSION}
        Append To List  ${provisionwatcher_list}  ${json}
    END
    Set Test Variable  ${provisionwatcher}  ${provisionwatcher_list}

Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    Generate Multiple Device Services Sample
    Create Device Service ${deviceService}
    Generate Multiple Device Profiles Sample
    Create Device Profile ${deviceProfile}
    ${provisionwatcher_1}=  Set provision watcher values  Device-Service-${index}-1  Test-Profile-1
    ${provisionwatcher_2}=  Set provision watcher values  Device-Service-${index}-2  Test-Profile-2
    Set To Dictionary  ${provisionwatcher_2}  name=Test-Provision-Watcher-Locked
    Set To Dictionary  ${provisionwatcher_2}  adminState=LOCKED
    ${profile}=  Load yaml file "core-metadata/deviceprofile/Test-Profile-3.yaml" and convert to dictionary
    ${autoEvent}=  Set autoEvents values  20s  true  ${profile}[deviceResources][0][name]
    ${autoEvents}=  Create List  ${autoEvent}
    ${provisionwatcher_3}=  Set provision watcher values  Device-Service-${index}-3  Test-Profile-3
    Set To Dictionary  ${provisionwatcher_3}  name=Test-Provision-Watcher-AutoEvents
    Set To Dictionary  ${provisionwatcher_3}  autoEvents=${autoEvents}
    Generate Provision Watchers  ${provisionwatcher_1}  ${provisionwatcher_2}  ${provisionwatcher_3}

Set provision watcher values
    [Arguments]  ${device_service_name}  ${device_profile_name}
    ${data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/provisionwatcher_data.json  encoding=UTF-8
    ${provisionwatcher}=  Evaluate  json.loads('''${data}''')  json
    Set To Dictionary  ${provisionwatcher}  serviceName=${device_service_name}
    Set To Dictionary  ${provisionwatcher}  profileName=${device_profile_name}
    [Return]  ${provisionwatcher}

Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample
    Delete Multiple Provision Watchers By Names
    ...  Test-Provision-Watcher  Test-Provision-Watcher-Locked  Test-Provision-Watcher-AutoEvents
    Delete multiple device services by names
    ...  Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    Delete multiple device profiles by names
    ...  Test-Profile-1  Test-Profile-2  Test-Profile-3

Create A Provision Watcher Sample With Associated Test-Device-Service And ${device_profile_name}
    Generate A Device Service Sample
    Create Device Service ${deviceService}
    Generate A Device Profile Sample  ${device_profile_name}
    Create Device Profile ${deviceProfile}
    ${provisionwatcher}=  Set Provision Watcher Values  Test-Device-Service  ${device_profile_name}
    Generate Provision Watchers  ${provisionwatcher}
    Create provision watcher ${provisionwatcher}

Set ProfileChange.${config}=${value} For Core-Metadata On Consul
   ${path}=  Set Variable  /v1/kv/edgex/core/${CONSUL_CONFIG_VERSION}/core-metadata/Writable/ProfileChange/${config}
   Update Service Configuration On Consul  ${path}  ${value}
   Sleep  1s  # Waiting for the configuration updating
