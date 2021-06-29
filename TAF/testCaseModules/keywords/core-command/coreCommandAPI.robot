*** Settings ***
Library   OperatingSystem
Library   RequestsLibrary
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot

*** Variables ***
${coreCommandUrl}    ${URI_SCHEME}://${BASE_URL}:${CORE_COMMAND_PORT}
${deviceUri}         /api/${API_VERSION}/device

*** Keywords ***
Query all deviceCoreCommands
    Create Session  Core Command  url=${coreCommandUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Command  ${deviceUri}/all  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}

Query all deviceCoreCommands with ${parameter}=${value}
    Create Session  Core Command  url=${coreCommandUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Command  ${deviceUri}/all  params=${parameter}=${value}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Query deviceCoreCommands by device name
    [Arguments]  ${device_name}
    Create Session  Core Command  url=${coreCommandUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Command  ${deviceUri}/name/${device_name}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail  "The device ${device_name} is not found"

Get specified device ${device} read command ${command}
    Create Session  Core Command  url=${coreCommandUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Command  ${deviceUri}/name/${device}/${command}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Get device ${device} read command ${command} with ${params}
    Create Session  Core Command  url=${coreCommandUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Command  ${deviceUri}/name/${device}/${command}  params=${params}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response}!=200  fail

Set specified device ${device} write command ${command} with ${data}
    Create Session  Core Command  url=${coreCommandUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  PUT On Session  Core Command  ${deviceUri}/name/${device}/${command}  json=${data}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Delete device virtual pre-define devices
    Remove Directory  ${WORK_DIR}/TAF/config/${PROFILE}/res  recursive=True
    Delete Multiple Devices By Names  Random-Boolean-Device  Random-Integer-Device  Random-UnsignedInteger-Device
    ...                               Random-Float-Device  Random-Binary-Device
    Delete Multiple Device Profiles By Names  Random-Boolean-Device  Random-Integer-Device  Random-UnsignedInteger-Device
    ...                                       Random-Float-Device  Random-Binary-Device
    Delete Device Service By Name  device-virtual
    # delete all events including auto events
    Delete all events by age

Update device ${deviceName} with ${property}=${value}
  # property: AdminState, operatingState
  ${update_dict}=  Create Dictionary  name=${deviceName}  ${property}=${value}
  Generate Devices  ${update_dict}
  Update devices ${Device}

