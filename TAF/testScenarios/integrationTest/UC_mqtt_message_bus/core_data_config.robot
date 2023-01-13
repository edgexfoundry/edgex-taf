*** Settings ***
Documentation  Configrations
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Run Keyword And Ignore Error  Stop Services  scalability-test-mqtt-export  app-service-mqtt-export  # No data received from the both services
Suite Teardown  Run Keywords  Run Teardown Keywords
...             AND  Terminate All Processes  kill=True
Force Tags   MessageBus=MQTT

*** Variables ***
${SUITE}              Core-Data-Configrations
${DATA_CONSOL_PATH}   ${CONSUL_CONFIG_BASE_ENDPOINT}/core-data

*** Test Cases ***
CoreConfig001 - Set core-data MessageBus.Topics.SubscribeTopic not match device-virtual PublishTopicPrefix
    Given Run MQTT Subscriber Progress And Output  edgex/events/device/#
    And Set Test Variable  ${device_name}  messagebus-mqtt-core-2
    And Set MessageBus Topics/SubscribeTopic=edgex/events/custom/# For core-data On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT8_RW with ds-pushevent=true
    Then Should Return Status Code "200" And event
    And Event Has Been Recevied By MQTT Subscriber
    And Event Is Not Pushed To Core Data
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Set MessageBus Topics/SubscribeTopic=edgex/events/device/# For core-data On Consul
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

CoreConfig002 - Customize core-data MessageBus.PublishTopicPrefix
    Given Run MQTT Subscriber Progress And Output  edgex/events/custom/#
    And Set Test Variable  ${device_name}  messagebus-mqtt-core-3
    And Set MessageBus Topics/PublishTopicPrefix=edgex/events/custom For core-data On Consul
    And Update Service Configuration On Consul  ${DATA_CONSOL_PATH}/Writable/LogLevel  DEBUG
    And Create Device For device-virtual With Name ${device_name}
    When Create An Event With ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT8_RW
    Then Should Return Status Code "201" And id
    And MQTT Subscriber Received Event is the Same As Service Log
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Set MessageBus Topics/PublishTopicPrefix=edgex/events/core For core-data On Consul
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

CoreConfig003 - Set core-data MessageBus.Optional.Qos (SUBSCRIBE)
    [Tags]  backward-skip
    Given Set Test Variable  ${device_name}  messagebus-mqtt-core-4
    And Set MessageBus Optional/Qos=2 For core-data On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT8_RW with ds-pushevent=true
    Then Should Return Status Code "200" And event
    And Event Has Been Pushed To Core Data
    And Verify MQTT Broker Qos
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Set MessageBus Optional/Qos=0 For core-data On Consul

*** Keywords ***
Set MessageBus ${key}=${value} For core-data On Consul
    ${path}=  Set Variable  ${DATA_CONSOL_PATH}/MessageBus/${key}
    Update Service Configuration On Consul  ${path}  ${value}
    Restart Services  data
    ${timestamp}  get current epoch time
    Set Test Variable  ${log_timestamp}  ${timestamp}

Event Has Been Recevied By MQTT Subscriber
    ${received_event}  Get file  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}
    Should Contain  ${received_event}  ${device_name}  No Event is not received by mqtt subscriber
    Should Contain  ${received_event}  CorrelationID  No CorrelationID Found in Event

Create An Event With ${device_name} and command ${command_name}
    Generate Event Sample  Event  ${device_name}  ${PREFIX}-Sample-Profile  ${PREFIX}_GenerateDeviceValue_UINT8_RW  Simple Reading  
    Create Event With ${device_name} And ${PREFIX}-Sample-Profile And ${PREFIX}_GenerateDeviceValue_UINT8_RW


Verify MQTT Broker Qos
    ${timestamp}=  Evaluate  int(${log_timestamp})-30
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh mqtt-broker ${timestamp}
    ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    Should Contain  ${logs.stdout}  core-data 2 edgex/events/device/#
    ${subscribe_log}  Get Lines Containing String  ${logs.stdout}  Sending PUBLISH to core-data
    Should Contain  ${subscribe_log}   q0  # because device-virtual QoS=0

MQTT Subscriber Received Event is the Same As Service Log
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh core-data ${log_timestamp}
    ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    ${correlation_line}  Get Lines Containing String  ${logs.stdout}.encode()  Event Published to MessageBus
    ${correlation_id}  Fetch From Right  ${correlation_line}  Correlation-id:
    ${correlation_id}  Fetch From Left  ${correlation_id}  "
    ${received_event}  Get file  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}
    Should Not Be Empty  ${correlation_id}  No Event Log Found in Service Log
    Should Not Be Empty  ${received_event}  No Event Received by MQTT Subscriber
    Should Contain  ${received_event}  ${correlation_id.strip()}  Event correlation_id is Different With Service Log
