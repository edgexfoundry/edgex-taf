*** Settings ***
Documentation  Configrations
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Delete all events by age
                ...      AND  Run Teardown Keywords
Force Tags  MessageBus=redis

*** Variables ***
${SUITE}              Configrations

*** Test Cases ***
Config001 - Verify the return value when Data Transform is true and shift field is set
    ${set_data}  Create Dictionary  ${PREFIX}_DeviceValue_UINT32_RW=4294901760
    Given Create Device For ${SERVICE_NAME} With Name Transform-Device-1
    And Set specified device ${device_name} write command ${PREFIX}_GenerateDeviceValue_UINT32_RW with ${set_data}
    When Retrive device data by device ${device_name} and command ${PREFIX}_DeviceValue_UINT32_RW
    Then Should return status code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Integers  65535  ${content}[event][readings][0][value]
    [Teardown]  Delete device by name ${device_name}

Config002 - Verify the return value when Data Transform is false and shift field is set
    ${set_data}  Create Dictionary  ${PREFIX}_DeviceValue_UINT32_RW=4294901760
    Given Set Device DataTransform to false For ${SERVICE_NAME} On Consul
    And Create Device For ${SERVICE_NAME} With Name Transform-Device-2
    And Set specified device ${device_name} write command ${PREFIX}_GenerateDeviceValue_UINT32_RW with ${set_data}
    When Retrive device data by device ${device_name} and command ${PREFIX}_DeviceValue_UINT32_RW
    Then Should return status code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Integers  4294901760  ${content}[event][readings][0][value]
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Set Device DataTransform to true For ${SERVICE_NAME} On Consul


Config003 - Verfiy reading contains units when ReadingUnits is true
    [Tags]  backward-skip
    Given Create Device For ${SERVICE_NAME} With Name ReadingUnits-True
    And Retrive Device Data By Device ${device_name} And Command ${PREFIX}_DeviceValue_INT8_R
    When Query Readings By Device Name  ${device_name}
    Then Should Return Status Code "200"
    And Should Contain  ${content}[readings][0]  units
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device By Name ${device_name}

Config004 - Verfiy reading contains units when ReadingUnits is false
    [Tags]  backward-skip
    Given Set Writable.Reading.ReadingUnits to false For ${SERVICE_NAME} On Consul
    And Create Device For ${SERVICE_NAME} With Name ReadingUnits-False
    And Retrive Device Data By Device ${device_name} And Command ${PREFIX}_DeviceValue_INT8_R
    When Query Readings By Device Name  ${device_name}
    Then Should Return Status Code "200"
    And Should Not Contain  ${content}[readings][0]  units
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set Writable.Reading.ReadingUnits to true For ${SERVICE_NAME} On Consul
                ...      AND  Delete Device By Name ${device_name}


*** Keywords ***
Set Device ${config} to ${value} For ${service_name} On Consul
    ${path}=  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/${service_name}/Device/${config}
    Update Service Configuration On Consul  ${path}  ${value}
    Restart Services  device-virtual

Set Writable.Reading.ReadingUnits to ${value} For ${service_name} On Consul
    ${path}=  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/${service_name}/Writable/Reading/ReadingUnits
    Update Service Configuration On Consul  ${path}  ${value}

Retrive device data by device ${device_name} and command ${command}
    ${timestamp}  Get current milliseconds epoch time
    Get device data by device ${device_name} and command ${command} with ds-pushevent=true
    Set Test Variable  ${timestamp}  ${timestamp}
    sleep  500ms
