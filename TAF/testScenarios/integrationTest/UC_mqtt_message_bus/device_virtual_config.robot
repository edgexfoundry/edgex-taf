*** Settings ***
Documentation  Configrations
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Run Keyword And Ignore Error  Stop Services  scalability-test-mqtt-export  app-service-mqtt-export  # No data received from the both services
Suite Teardown  Run Teardown Keywords
Force Tags   MessageQueue=MQTT

*** Variables ***
${SUITE}              Configrations

*** Test Cases ***
Config001 - Set MessageQueue.Protocol to MQTT
    Given Run MQTT Subscriber Progress And Output  edgex/events/device/#
    And Set Test Variable  ${device_name}  messageQueue-mqtt
    And Set Writable LogLevel To Debug For device-virtual On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Retrive device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT8_RW
    Then Should Return Status Code "200" And event
    And Event Has Been Recevied By MQTT Subscriber
    And Event Has Been Pushed To Core Data
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

Config002 - Modify MessageQueue.PublishTopicPrefix and receive data from the topic correctly
    Given Set Test Variable  ${device_name}  messagebus-true-device-5
    And Run MQTT Subscriber Progress And Output  edgex/events/custom/#
    And Set MessageQueue PublishTopicPrefix=edgex/events/custom For device-virtual On Consul
    And Set MessageQueue SubscribeTopic=edgex/events/custom/# For core-data On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Retrive device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW
    Then Should Return Status Code "200" And event
    And Event Has Been Pushed To Core Data
    And Event Has Been Recevied By MQTT Subscriber
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set MessageQueue PublishTopicPrefix=edgex/events/device For device-virtual On Consul
                ...      AND  Set MessageQueue SubscribeTopic=edgex/events/device/# For core-data On Consul

Config003 - Set device-virtual MessageQueue.Optional.Qos (PUBLISH)
    [Tags]  backward-skip
    Given Set Test Variable  ${device_name}  messagebus-true-device-6
    And Create Device For device-virtual With Name ${device_name}
    And Set MessageQueue Optional/Qos=2 For device-virtual On Consul
    And Set MessageQueue Optional/Qos=1 For core-data On Consul
    When Retrive device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT8_RW
    Then Should Return Status Code "200" And event
    And Event Has Been Pushed To Core Data
    And Verify MQTT Broker Qos
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Set MessageQueue Optional/Qos=0 For device-virtual On Consul
                ...           AND  Set MessageQueue Optional/Qos=0 For core-data On Consul

*** Keywords ***
Set MessageQueue ${key}=${value} For ${service_name} On Consul
    ${path}=  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/${service_name}/MessageQueue/${key}
    Update Service Configuration On Consul  ${path}  ${value}
    ${service}  Run Keyword If  "data" in "${service_name}"  Set Variable  data
                ...       ELSE  Set Variable  ${service_name}
    Restart Services  ${service}

Set Writable LogLevel To Debug For ${service_name} On Consul
    ${path}=  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/${service_name}/Writable/LogLevel
    Update Service Configuration On Consul  ${path}  DEBUG

Retrive device data by device ${device_name} and command ${command}
    ${timestamp}  get current epoch time
    Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT8_RW with ds-pushevent=yes
    Set Test Variable  ${log_timestamp}  ${timestamp}
    sleep  500ms

Event Has Been Recevied By MQTT Subscriber
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh device-virtual ${log_timestamp}
    ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    ${correlation_line}  Get Lines Containing String  ${logs.stdout}.encode()  Correlation-ID
    ${correlation_id}  Fetch From Right  ${correlation_line}  X-Correlation-ID:
    ${correlation_id}  Fetch From Left  ${correlation_id.strip()}  "

    ${received_event}  Get file  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}
    run keyword if  "${correlation_id}" not in """${received_event}"""
    ...             fail  Event is not received by mqtt subscriber

Verify MQTT Broker Qos
    ${result} =  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh mqtt-broker ${log_timestamp}
    ...          shell=True  stderr=STDOUT  output_encoding=UTF-8
    Log  ${result.stdout}
    ${publish_log}  Get Lines Containing String  ${result.stdout}  Received PUBLISH from device-virtual
    Should Contain  ${publish_log}  q2
    ${subscribe_log}   Get Lines Containing String  ${result.stdout}  Sending PUBLISH to core-data
    Should Contain  ${subscribe_log}   q1
