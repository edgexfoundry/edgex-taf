*** Settings ***
Library      TAF/testCaseModules/keywords/setup/edgex.py
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run keywords   Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                   AND  Set UseMessageBus=false For device-virtual On Consul
Suite Teardown  Run keywords  Set UseMessageBus=true For device-virtual On Consul
...                      AND  Run Teardown Keywords
Force Tags      MessageQueue=redis

*** Variables ***
${SUITE}          Device Service Test When MessageBus Set To False
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/messagebus_false.log


*** Test Cases ***
DeviceService005-Send get command with parameters ds-pushevent=no and ds-returnevent=no when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-5
    ${params}  Create Dictionary  ds-pushevent=no  ds-returnevent=no
    ${handle}  Run Redis Subscriber Progress And Output
    Given Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200"
    And Should Be Empty  ${content}
    And Event Is Not Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

DeviceService006-Send get command with parameters ds-pushevent=yes and ds-returnevent=no when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-6
    ${params}  Create Dictionary  ds-pushevent=yes  ds-returnevent=no
    ${handle}  Run Redis Subscriber Progress And Output
    Given Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200"
    And Should Be Empty  ${content}
    And Event Has Been Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

DeviceService007-Send get command with parameters ds-pushevent=no and ds-returnevent=yes when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-7
    ${params}  Create Dictionary  ds-pushevent=no  ds-returnevent=yes
    ${handle}  Run Redis Subscriber Progress And Output
    Given Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event Is Not Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

DeviceService008-Send get command with parameters ds-pushevent=yes and ds-returnevent=yes when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-8
    ${params}  Create Dictionary  ds-pushevent=yes  ds-returnevent=yes
    ${handle}  Run Redis Subscriber Progress And Output
    Given Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event Has Been Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

*** Keywords ***
Set UseMessageBus=${value} For device-virtual On Consul
   ${path}=  Set Variable  /v1/kv/edgex/devices/${CONSUL_CONFIG_VERSION}/device-virtual/Device/UseMessageBus
   Update Service Configuration On Consul  ${path}  ${value}
   Restart Services  device-virtual
