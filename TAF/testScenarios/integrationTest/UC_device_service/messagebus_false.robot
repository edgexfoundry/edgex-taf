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
Force Tags      MessageBus=redis

*** Variables ***
${SUITE}          Device Service Test When MessageBus Set To False
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/messagebus_false.log


*** Test Cases ***
DeviceService006-Send get command with parameters ds-pushevent=false and ds-returnevent=false when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-5
    ${params}  Create Dictionary  ds-pushevent=false  ds-returnevent=false
    Given Run Redis Subscriber Progress And Output  edgex.events.device.*  ${device_name}
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200"
    And Should Be Empty  ${content}
    And Event Is Not Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_redis}  kill=True

DeviceService007-Send get command with parameters ds-pushevent=true and ds-returnevent=false when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-6
    ${params}  Create Dictionary  ds-pushevent=true  ds-returnevent=false
    Given Run Redis Subscriber Progress And Output  edgex.events.device.*  ${device_name}
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200"
    And Should Be Empty  ${content}
    And Event Has Been Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_redis}  kill=True

DeviceService008-Send get command with parameters ds-pushevent=false and ds-returnevent=true when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-7
    ${params}  Create Dictionary  ds-pushevent=false  ds-returnevent=true
    Given Run Redis Subscriber Progress And Output  edgex.events.device.*  ${device_name}
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event Is Not Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_redis}  kill=True

DeviceService009-Send get command with parameters ds-pushevent=true and ds-returnevent=true when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-8
    ${params}  Create Dictionary  ds-pushevent=true  ds-returnevent=true
    Given Run Redis Subscriber Progress And Output  edgex.events.device.*  ${device_name}
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event Has Been Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_redis}  kill=True

DeviceService010-Create Events by REST API when messagebus is disabled
    Set Test Variable  ${device_name}  messagebus-false-device-10
    Given Run Redis Subscriber Progress And Output  edgex.events.core.*  ${device_name}
    And Create Device For device-virtual With Name ${device_name}
    And Generate Event Sample  Event  ${device_name}  ${PREFIX}-Sample-Profile  ${PREFIX}_GenerateDeviceValue_UINT8_RW  Simple Reading  
    When Create Event With ${device_name} And ${PREFIX}-Sample-Profile And ${PREFIX}_GenerateDeviceValue_UINT8_RW
    Then Should Return Status Code "201" And id
    And Event With Device ${device_name} Should Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_redis}  kill=True

*** Keywords ***
Set UseMessageBus=${value} For device-virtual On Consul
    ${path}=  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/device-virtual/Device/UseMessageBus
    Update Service Configuration On Consul  ${path}  ${value}
    Restart Services  device-virtual
    Set Suite Variable  ${url}  ${deviceServiceUrl}
    FOR  ${INDEX}  IN RANGE  5
        Query Ping
        Run Keyword If  ${response} == 200  Exit For Loop
        ...       ELSE  Sleep  5s
    END
