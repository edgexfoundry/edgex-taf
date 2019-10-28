*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  TAF.utils.src.data.value_checker
Resource  ./coreMetadataAPI.robot

*** Variables ***
${deviceServiceUrl}  http://${BASE_URL}:${DEVICE_SERVICE_PORT}
${dsDeviceUri}   /api/v1/device
${dsCallBack}    /api/v1/callback


*** Keywords ***
Invoke Get command by device id "${deviceId}" and command name "${commandName}"
    Create Session  Device Service  url=${deviceServiceUrl}
    ${resp}=  Get Request  Device Service    ${dsDeviceUri}/${deviceId}/${commandName}
    run keyword if  ${resp.status_code}!=200  log   ${resp.content}
    run keyword if  ${resp.status_code}!=200  log   "Invoke Get command failed"
    ${responseBody}=  run keyword if  ${resp.status_code}==200   evaluate  json.loads('''${resp.content}''')  json
    run keyword if  ${resp.status_code}==200  set environment variable   readingValue  ${responseBody}[readings][0][value]
    set environment variable  response  ${resp.status_code}

Invoke Get command by device name "${deviceName}" and command name "${commandName}"
    Create Session  Device Service  url=${deviceServiceUrl}
    ${resp}=  Get Request  Device Service    ${dsDeviceUri}/name/${deviceName}/${commandName}
    run keyword if  ${resp.status_code}!=200  log   ${resp.content}
    run keyword if  ${resp.status_code}!=200  log   "Invoke Get command failed"
    ${responseBody}=  run keyword if  ${resp.status_code}==200   evaluate  json.loads('''${resp.content}''')  json
    run keyword if  ${resp.status_code}==200  set environment variable   readingValue  ${responseBody}[readings][0][value]
    set environment variable  response  ${resp.status_code}

Invoke Get command name "${commandName}" for all devices
    Create Session  Device Service  url=${deviceServiceUrl}
    ${resp}=  Get Request  Device Service    ${dsDeviceUri}/all/${commandName}
    run keyword if  ${resp.status_code}!=200  log   "Invoke Get command failed"
    ${deviceCommandBody}=  run keyword if  ${resp.status_code}==200  evaluate  json.loads('''${resp.content}''')  json
    return from keyword if  ${resp.status_code}==200    ${deviceCommandBody}
    set environment variable  response  ${resp.status_code}

Invoke Put command by device id "${deviceId}" and command name "${commandName}" with request body "${Resource}":"${value}"
    Create Session  Device Service  url=${deviceServiceUrl}
    ${data}=    Create Dictionary   ${Resource}=${value}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Put Request  Device Service    ${dsDeviceUri}/${deviceId}/${commandName}  json=${data}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log   ${resp.content}
    run keyword if  ${resp.status_code}!=200  log   "Invoke Put command failed"
    set environment variable  response  ${resp.status_code}

Invoke Put command by device name "${deviceName}" and command name "${commandName}" with request body "${Resource}":"${value}"
    Create Session  Device Service  url=${deviceServiceUrl}
    ${data}=    Create Dictionary   ${Resource}=${value}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Put Request  Device Service    ${dsDeviceUri}/name/${deviceName}/${commandName}  json=${data}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log   ${resp.content}
    run keyword if  ${resp.status_code}!=200  log   "Invoke Put command failed"
    set environment variable  response  ${resp.status_code}

Invoke Post callback for the device "${callback_id}" with action type "${action_type}"
    Create Session  Device Service  url=${deviceServiceUrl}
    ${data}=    Create Dictionary   'id'=${callback_id}   'actionType'=${action_type}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Device Service    ${dsCallBack}  json=${data}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log   ${resp.content}
    run keyword if  ${resp.status_code}!=200  log   "Invoke Post Callback command failed"
    set environment variable  response  ${resp.status_code}

Invoke Delete callback for the device "${device_id}" with action type "${action_type}"
    Create Session  Device Service  url=${deviceServiceUrl}
    ${data}=    Create Dictionary   'id'=${device_id}   'actionType'=${action_type}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Delete Request  Device Service    ${dsCallBack}  json=${data}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log   ${resp.content}
    run keyword if  ${resp.status_code}!=200  log   "Invoke Delete Callback command failed"
    set environment variable  response  ${resp.status_code}

Device resource should be updated to "${value}"
    ${deviceId}=  get environment variable  deviceId
    ${commandName}=  get variable value  ${readingName}
    Invoke Get command by device id "${deviceId}" and command name "${commandName}"
    ${deviceResourceValue}=  get environment variable  deviceResourceValue
    should be equal  ${value}   ${deviceResourceValue}

DS should return status code "200"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 200

DS should return status code "400"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 400

DS should return status code "404"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 404

DS should return status code "423"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 423

Value should be "${dataType}"
    ${returnValue}=     get environment variable  readingValue
    ${status}=  check value range   ${returnValue}  ${dataType}
    should be true  ${status}

DS should receive a Device Post callback
    Create Session  Device Service  url=${deviceServiceUrl}
    ${resp}=  Get Request  Device Service    ${deviceServiceUrl}/${dsCallBack}
    log  ${resp.content}
    set environment variable  response  ${resp.status_code}


