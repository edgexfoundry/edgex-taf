*** Settings ***
Documentation  Configurations
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Delete all events by age
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}              Configurations

*** Test Cases ***
Config001 - Verify the return value after writing with shift field set when Data Transform is true
# Use W(with shift) to write and RW(no shift) to read. Value is transformed during RW write only.
    ${set_data}  Create Dictionary  Modbus_DeviceValue_UINT32_W=4294901760
    Given Set Test Variable  ${PREFIX}  Modbus
    And Create Device For device-modbus With Name Transform-Device-1
    And Set specified device ${device_name} write command ${PREFIX}_GenerateDeviceValue_UINT32_W with ${set_data}
    When Retrieve device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT32_RW
    Then Should return status code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Integers  65535  ${content}[event][readings][0][value]
    [Teardown]  Delete device by name ${device_name}

Config002 - Verify the return value after reading with shift field set when Data Transform is true
# Use RW (no shift) to write and R (with shift) to read. Value is transformed during RW read only.
    Dump Last 100 lines Log  device-modbus
    ${set_data}  Create Dictionary  Modbus_DeviceValue_UINT32_RW=65535
    Given Set Test Variable  ${PREFIX}  Modbus
    And Create Device For device-modbus With Name Transform-Device-2
    And Set specified device ${device_name} write command ${PREFIX}_GenerateDeviceValue_UINT32_RW with ${set_data}
    When Retrieve device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT32_R
    Then Should return status code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Integers  4294901760  ${content}[event][readings][0][value]
    [Teardown]  Delete device by name ${device_name}

Config003 - Verify the return value after reading with shift field set when Data Transform is false
# Use RW (no shift) to write and R (with shift) to read. No value is transformed
    Dump Last 100 lines Log  device-modbus
    ${set_data}  Create Dictionary  Modbus_DeviceValue_UINT32_RW=4294901760
    Given Set Device DataTransform to false For device-modbus On Registry Service
    And Set Test Variable  ${PREFIX}  Modbus
    And Create Device For device-modbus With Name Transform-Device-3
    And Set specified device ${device_name} write command ${PREFIX}_GenerateDeviceValue_UINT32_RW with ${set_data}
    When Retrieve device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT32_R
    Then Should return status code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Integers  4294901760  ${content}[event][readings][0][value]
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Set Device DataTransform to true For device-modbus On Registry Service

Config004 - Verify reading contains units when ReadingUnits is true
    Given Set Writable.Reading.ReadingUnits to true For ${SERVICE_NAME} On Registry Service
    And Create Device For ${SERVICE_NAME} With Name ReadingUnits-True
    And Retrieve Device Data By Device ${device_name} And Command ${PREFIX}_GenerateDeviceValue_INT8_R
    When Query Readings By Device Name  ${device_name}
    Then Should Return Status Code "200"
    And Should Contain  ${content}[readings][0]  units
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set Writable.Reading.ReadingUnits to false For ${SERVICE_NAME} On Registry Service
                ...      AND  Delete Device By Name ${device_name}

Config005 - Verify reading contains units when ReadingUnits is false
    Given Set Writable.Reading.ReadingUnits to false For ${SERVICE_NAME} On Registry Service
    And Create Device For ${SERVICE_NAME} With Name ReadingUnits-False
    And Retrieve Device Data By Device ${device_name} And Command ${PREFIX}_GenerateDeviceValue_INT8_R
    When Query Readings By Device Name  ${device_name}
    Then Should Return Status Code "200"
    And Should Not Contain  ${content}[readings][0]  units
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set Writable.Reading.ReadingUnits to true For ${SERVICE_NAME} On Registry Service
                ...      AND  Delete Device By Name ${device_name}

Config006 - Verify OperationalState when AllowedFails is default with failed device requests
# Default AllowedFails is 0(set to zero to disable automatic disablement of devices)
    ${set_data}  Create Dictionary  Modbus_DeviceValue_INT16_RW=60
    Given Set Test Variable  ${device_name}  Modbus-Test-Device
    And Create Unavailable Modbus device
    When Set specified device ${device_name} write command Modbus_GenerateDeviceValue_INT16_RW with ${set_data}
    Then Device OperationalState Should Be UP
    [Teardown]  Delete Device By Name ${device_name}

Config007 - Verify OperationalState when AllowedFails is 1 and DeviceDownTimeout is default with failed device requests
# Default DeviceDownTimeout is 0(set to zero to disable automatic re-enablement of devices)
    ${set_data}  Create Dictionary  Modbus_DeviceValue_INT16_RW=60
    Given Set Test Variable  ${device_name}  Modbus-Test-Device
    And Create Unavailable Modbus Device
    And Set Device AllowedFails to 1 For device-modbus On Registry Service
    When Set specified device ${device_name} write command Modbus_GenerateDeviceValue_INT16_RW with ${set_data}
    Then Device OperationalState Should Be DOWN
    And Device OperationalState Should Be DOWN After Retrying To Connect To Device
    [Teardown]  Run Keywords  Set Device AllowedFails to 0 For device-modbus On Registry Service
                ...      AND  Delete Device By Name ${device_name}

Config008 - Verify OperationalState when AllowedFails is 1 and DeviceDownTimeout=1 with failed device requests
    ${set_data}  Create Dictionary  Modbus_DeviceValue_INT16_RW=60
    Given Set Test Variable  ${device_name}  Modbus-Test-Device
    And Create Unavailable Modbus Device
    And Set Device AllowedFails to 1 For device-modbus On Registry Service
    And Set Device DeviceDownTimeout to 1 For device-modbus On Registry Service
    When Set specified device ${device_name} write command Modbus_GenerateDeviceValue_INT16_RW with ${set_data}
    Then Device OperationalState Should Be DOWN
    And Device OperationalState Should Be UP After Retrying To Connect To Device
    [Teardown]  Run Keywords  Set Device AllowedFails to 0 For device-modbus On Registry Service
                ...      AND  Set Device DeviceDownTimeout to 0 For device-modbus On Registry Service
                ...      AND  Delete Device By Name ${device_name}

*** Keywords ***
Set Device ${config} to ${value} For ${service_name} On Registry Service
    ${path}=  Set Variable  /${service_name}/Device/${config}
    Update Service Configuration  ${path}  ${value}
    Restart Services  ${service_name}

Set Writable.Reading.ReadingUnits to ${value} For ${service_name} On Registry Service
    ${path}=  Set Variable  /${service_name}/Writable/Reading/ReadingUnits
    Update Service Configuration  ${path}  ${value}

Retrieve device data by device ${device_name} and command ${command}
    ${timestamp}  Get current milliseconds epoch time
    Get device data by device ${device_name} and command ${command} with ds-pushevent=true
    Set Test Variable  ${timestamp}  ${timestamp}
    sleep  500ms

Device OperationalState Should Be ${value}
    sleep  2s
    Query device by name  ${device_name}
    Should Be Equal  ${content}[device][operatingState]  ${value}

Device OperationalState Should Be ${value} After Retrying To Connect To Device
    ${update_device}  Create Dictionary  name=${Device}[0][device][name]  protocols=${Device}[0][device][protocols]
    Set To Dictionary  ${update_device}[protocols][modbus-tcp]  Port=${1502}
    Generate Devices  ${update_device}
    Update devices ${Device}
    Wait Until Keyword Succeeds  5x  5s  Device OperationalState Should Be ${value}
