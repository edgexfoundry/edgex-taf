*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run keywords   Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      MessageQueue=redis

*** Variables ***
${SUITE}          Device Service Test When MessageBus Set To True
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/messagebus_true.log


# No nessecary to update consul, because default setting is MessageBus=true
*** Test Cases ***
DeviceService001-Send get command with parameters ds-pushevent=no and ds-returnevent=no when messagebus is enabled
    Set Test Variable  ${device_name}  messagebus-true-device-1
    ${params}  Create Dictionary  ds-pushevent=no  ds-returnevent=no
    ${handle}  Run Redis Subscriber Progress And Output  edgex.events.device.*
    Given Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200"
    And Event Is Not Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

DeviceService002-Send get command with parameters ds-pushevent=yes and ds-returnevent=no when messagebus is enabled
    Set Test Variable  ${device_name}  messagebus-true-device-2
    ${params}  Create Dictionary  ds-pushevent=yes  ds-returnevent=no
    ${handle}  Run Redis Subscriber Progress And Output  edgex.events.device.*
    Given Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200"
    And Event Has Been Pushed To Core Data
    And Event With Device ${device_name} Should Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

DeviceService003-Send get command with parameters ds-pushevent=no and ds-returnevent=yes when messagebus is enabled
    Set Test Variable  ${device_name}  messagebus-true-device-3
    ${params}  Create Dictionary  ds-pushevent=no  ds-returnevent=yes
    ${handle}  Run Redis Subscriber Progress And Output  edgex.events.device.*
    Given Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event Is Not Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

DeviceService004-Send get command with parameters ds-pushevent=yes and ds-returnevent=yes when messagebus is enabled
    Set Test Variable  ${device_name}  messagebus-true-device-4
    ${params}  Create Dictionary  ds-pushevent=yes  ds-returnevent=yes
    ${handle}  Run Redis Subscriber Progress And Output  edgex.events.device.*
    Given Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event Has Been Pushed To Core Data
    And Event With Device ${device_name} Should Be Received by Redis Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

DeviceService005-Customize PublishTopicPrefix works correctly when using Redis message bus
    Set Test Variable  ${device_name}  messagebus-true-device-5
    ${params}  Create Dictionary  ds-pushevent=yes  ds-returnevent=yes
    ${handle}  Run Redis Subscriber Progress And Output  edgex.events.custom.*
    Given Set PublishTopicPrefix=edgex/events/custom For device-virtual On Consul
    And Set SubscribeTopic=edgex/events/custom/# For core-data On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event With Device ${device_name} Should Be Received by Redis Subscriber ${subscriber_file}
    And Event Has Been Pushed To Core Data
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True
                ...           AND  Set PublishTopicPrefix=edgex/events/device For device-virtual On Consul
                ...           AND  Set SubscribeTopic=edgex/events/device/# For core-data On Consul

*** Keywords ***
Event With Device ${device_name} Should Be Received by Redis Subscriber ${filename}
    ${redis_subscriber}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${filename}  ${device_name}
    run keyword if  "${device_name}" not in """${redis_subscriber}"""
    ...             fail  No data received by redis subscriber

Set ${config}=${value} For ${service_name} On Consul
    ${service_layer}  Set Variable If  'device' in """${service_name}"""  devices
                      ...              'core' in """${service_name}"""  core
    ${path}=  Set Variable  /v1/kv/edgex/${service_layer}/${CONSUL_CONFIG_VERSION}/${service_name}/MessageQueue/${config}
    Update Service Configuration On Consul  ${path}  ${value}
    ${service}  Run Keyword If  'core' in """${service_name}"""  Fetch From Right  ${service_name}  -
                ...       ELSE  Set Variable  ${service_name}
    Restart Services  ${service}
