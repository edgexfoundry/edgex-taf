*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  TAF/testCaseModules/keywords/common/value_checker.py
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${deviceServiceUrl}  ${URI_SCHEME}://${BASE_URL}:${SERVICE_PORT}
${dsCallBack}    /api/${api_version}/callback
${dsDeviceUri}   /api/${api_version}/device


*** Keywords ***
Invoke Get command by device ${device_name} and command ${command}
    Create Session  Device Service  url=${deviceServiceUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Device Service    ${dsDeviceUri}/name/${device_name}/${command}  headers=${headers}  expected_status=any
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
    ${device}  Set device values  ${SERVICE_NAME}  Sample-Profile
    Set To Dictionary  ${device}  name=${name}
    Generate Devices  ${device}
    Create Device With ${Device}
    sleep  500ms
    Set Test Variable  ${device_name}  ${name}
