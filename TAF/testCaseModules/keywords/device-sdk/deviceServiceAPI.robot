*** Settings ***
Library     Process
Library     RequestsLibrary
Library     OperatingSystem
Library     TAF/testCaseModules/keywords/common/value_checker.py
Resource    TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource    TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource    TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot

*** Variables ***
${deviceServiceUrl}  ${URI_SCHEME}://${BASE_URL}:${SERVICE_PORT}
${dsCallBack}    /api/${API_VERSION}/callback
${dsDeviceUri}   /api/${API_VERSION}/device
${dsDiscoveryeUri}   /api/${API_VERSION}/discovery


*** Keywords ***
Invoke Get command by device ${device_name} and command ${command}
    Create Session  Device Service  url=${deviceServiceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Device Service    ${dsDeviceUri}/name/${device_name}/${command}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}
    ...       ELSE  Set Test variable   ${get_reading_value}  ${content}[event][readings][0][value]

Invoke Get command with params ${params} by device ${device_name} and command ${command}
    Create Session  Device Service  url=${deviceServiceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Device Service    ${dsDeviceUri}/name/${device_name}/${command}
    ...    params=${params}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}
    ...       ELSE  Set Test variable   ${get_reading_value}  ${content}[event][readings][0][value]

Invoke Set command by device ${deviceName} and command ${command} with request body ${Resource}:${value}
    Create Session  Device Service  url=${deviceServiceUrl}  disable_warnings=true
    ${data}=    Create Dictionary   ${Resource}=${value}
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${jwt_token}
    ${resp}=  PUT On Session  Device Service  ${dsDeviceUri}/name/${deviceName}/${command}  json=${data}  headers=${headers}
    ...       expected_status=any
    Run Keyword If  ${resp.status_code}!=500  Set Response to Test Variables  ${resp}
    ...       ELSE  Set Test Variable  ${response}  ${resp.status_code}
    Run keyword if  ${resp.status_code}!=200  log to console  ${content}

Value should be "${dataType}"
    ${status}=  check value range   ${get_reading_value}  ${dataType}
    should be true  ${status}

Get A Read Command
    @{data_types_skip_write_only}  Get All Read Commands
    ${data_type}  set variable  ${data_types_skip_write_only}[0][dataType]
    ${command}  set variable  ${data_types_skip_write_only}[0][commandName]
    ${reading_name}  set variable  ${data_types_skip_write_only}[0][readingName]
    ${random_value}  Get reading value with data type "${data_type}"
    ${set_reading_value}  convert to string  ${random_value}
    Set Test Variable  ${data_types_skip_write_only}  ${data_types_skip_write_only}
    Set Test Variable  ${command}  ${command}
    Set Test Variable  ${reading_name}  ${reading_name}
    Set Test Variable  ${set_reading_value}  ${set_reading_value}

Create Device For ${SERVICE_NAME} With Name ${name}
    ${device}  Run Keyword If  '${SERVICE_NAME}' == 'device-onvif-camera'  Set device values  device-onvif-camera  onvif-camera
               ...       ELSE  Set device values  ${SERVICE_NAME}  ${PREFIX}-Sample-Profile
    Set To Dictionary  ${device}  name=${name}
    Generate Devices  ${device}
    Create Device With ${Device}
    sleep  500ms
    Set Test Variable  ${device_name}  ${name}

Create ${number} Devices For ${SERVICE_NAME}
    ${device_list}  Create List
    FOR  ${INDEX}  IN RANGE  0  ${number}
        ${name}  Set Variable  Command-Device-${INDEX}
        Create Device For ${SERVICE_NAME} With Name ${name}
        Append To List  ${device_list}  ${name}
    END
    Set Test Variable  ${device_list}  ${device_list}

Run Discovery Request For Device Service
    Create Session  Device Service  url=${deviceServiceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Device Service    ${dsDiscoveryeUri}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  log to console  ${content}

## Used by device-service of integration-test
Event Is Not Pushed To Core Data
    Query all events
    ${number}  Get Length  ${content}[events]
    Should Be Equal As Integers  ${number}  0

Event Has Been Pushed To Core Data
    Query all events
    Should Return Status Code "200" And events
    Should Be Equal As Strings  ${content}[events][0][deviceName]  ${device_name}

Get device data by device ${device} and command ${command} with ${params}
    Get device ${device} read command ${command} with ${params}
    Should return status code "200"
    sleep  500ms

Event With Device ${device_name} Should Not Be Received by MQTT Subscriber ${filename}
    ${mqtt_subscriber}  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${filename}  ${device_name}
    Should Be Empty  ${mqtt_subscriber}

Event With Device ${device_name} Should Be Received by MQTT Subscriber ${filename}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  5x  1s  File Should Not Be Empty  ${WORK_DIR}/TAF/testArtifacts/logs/${filename}
    # Show last 100 lines for debug
    Get Service Config And Dump Last 100 lines Log  device-virtual  ${deviceServiceUrl}
    ${mqtt_subscriber}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${filename}  ${device_name}
    run keyword if  "${device_name}" not in """${mqtt_subscriber}"""
    ...             fail  No data received by mqtt subscriber

Create Unavailable Modbus device
     ${service}  Set Variable  device-modbus
     ${device}  Set device values  ${service}  Modbus-Sample-Profile
     ${protocols}=  Load data file "core-metadata/device_protocol.json" and get variable "${service}"
     Set To Dictionary  ${protocols}[modbus-tcp]  Port=123
     Set To Dictionary  ${device}  protocols=${protocols}
     Set To Dictionary  ${device}  name=${device_name}
     Generate Devices  ${device}
     Create Device With ${Device}
     sleep  500ms

Create events by get device command
    FOR  ${INDEX}  IN RANGE  0  3
        @{data_type_skip_write_only}  Get All Read Commands
        ${random_command}  Get random "commandName" from "${data_type_skip_write_only}"
        Invoke Get command with params ds-pushevent=true by device ${device_name} and command ${random_command}
    END
    FOR  ${INDEX}  IN RANGE  3
        Query all events
        Exit For Loop If    ${content}[totalCount] != 0
        Sleep  500ms
    END
    ${events_length}=   GET LENGTH  ${content}[events]
    run keyword if  ${events_length} == 0  fail  Events didn't create before clean up
