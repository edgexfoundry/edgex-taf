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

Invoke Get command with params ${parameter}=${value} by device ${device_name} and command ${command}
    Create Session  Device Service  url=${deviceServiceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Device Service    ${dsDeviceUri}/name/${device_name}/${command}
    ...    params=${parameter}=${value}  headers=${headers}  expected_status=any
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
    ${device}  Set device values  ${SERVICE_NAME}  ${PREFIX}-Sample-Profile
    Set To Dictionary  ${device}  name=${name}
    Generate Devices  ${device}
    Create Device With ${Device}
    sleep  500ms
    Set Test Variable  ${device_name}  ${name}

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

Run Redis Subscriber Progress And Output
    [Arguments]  ${topic}
    ${current_time}  get current epoch time
    ${secty}  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Set Variable  true
              ...       ELSE  Set Variable  false
    ${handle}  Start process  python ${WORK_DIR}/TAF/utils/src/setup/redis-subscriber.py ${topic} ${device_name} ${secty} &
    ...                shell=True  stdout=${WORK_DIR}/TAF/testArtifacts/logs/subscriber-${current_time}.log
    ...                stderr=${WORK_DIR}/TAF/testArtifacts/logs/error-${current_time}.log
    Set Test Variable  ${subscriber_file}  subscriber-${current_time}.log
    sleep  2s
    [Return]  ${handle}

Get device data by device ${device} and command ${command} with ${params}
    Get device ${device} read command ${command} with ${params}
    Should return status code "200"
    sleep  500ms

Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${filename}
    ${redis_subscriber}  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${filename}  ${device_name}
    Should Be Empty  ${redis_subscriber}

Event With Device ${device_name} Should Be Received by Redis Subscriber ${filename}
    ${redis_subscriber}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${filename}  ${device_name}
    run keyword if  "${device_name}" not in """${redis_subscriber}"""
    ...             fail  No data received by redis subscriber
