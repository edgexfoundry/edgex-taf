*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource        TAF/testCaseModules/keywords/core-command/externalSystem.robot
Suite Setup  Run keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      MessageQueue=MQTT  MessageQueue=redis  backward-skip

*** Variables ***
${SUITE}            North-South Messaging GET Negative Testcases
${LOG_FILE_PATH}    ${WORK_DIR}/TAF/testArtifacts/logs/north-south-messaging-get-negative.log


*** Test Cases ***
ErrNSMessagingGET001 - Query all DeviceCoreCommands with non-int value on offset
    Given Run MQTT Subscriber Progress And Output  ${QUERY_RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Query All Devices Commands With offset=invalid From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET002 - Query all DeviceCoreCommands with invalid offset range
    Given Create 3 Devices For device-virtual
    And Run MQTT Subscriber Progress And Output  ${QUERY_RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Query All Devices Commands With offset=10 From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run Keywords  Delete multiple devices by names  @{device_list}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET003 - Query all DeviceCoreCommands with non-int value on limit
    Given Run MQTT Subscriber Progress And Output  ${QUERY_RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Query All Devices Commands With limit=invalid From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET004 - Query DeviceCoreCommand with non-existent device name
    Given Set Test Variable  ${device_name}  ex-mqtt-query-non-existent
    And Run MQTT Subscriber Progress And Output  ${QUERY_RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Query Commands For ${device_name} From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET005 - Get non-existent device read command
    Given Set Test Variable  ${device_name}  ex-mqtt-get-non-existent
    And Set Random Read Command
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET006 - Get specified device non-existent read command
    Given Set Test Variable  ${device_name}  ex-mqtt-get-invalid-command
    And Set Test Variable  ${resource_name}  non-existent-resource
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET007 - Get specified device read command with invalid ds-returnevent
    Given Set Test Variable  ${device_name}  ex-mqtt-get-invalid-returnevent
    And Set Random Read Command
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command With ds-returnevent=invalid From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET008 - Get specified device read command with invalid ds-pushevent
    Given Set Test Variable  ${device_name}  ex-mqtt-get-invalid-pushevent
    And Set Random Read Command
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command With ds-pushevent=invalid From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET009 - Get specified device read command when device AdminState is locked
    Given Set Test Variable  ${device_name}  ex-mqtt-get-adminstate
    And Set Random Read Command
    And Create Device For device-virtual With Name ${device_name}
    And Update Device ${device_name} With adminState=LOCKED
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET010 - Get specified device read command when device OperatingState is down
    Given Set Test Variable  ${device_name}  ex-mqtt-get-operatingstate
    And Set Random Read Command
    And Create Device For device-virtual With Name ${device_name}
    And Update Device ${device_name} With operatingState=DOWN
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET011 - Get unavailable HTTP device read command
    # device-onvif-camera
    Given Set Test Variable  ${device_name}  Camera01
    And Set Test Variable  ${resource_name}  NetworkConfiguration
    And Create Device For device-onvif-camera With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingGET012 - Get unavailable Modbus device read command
    # device-modbus
    Given Set Test Variable  ${device_name}  ex-mqtt-get-modbus
    And Set Test Variable  ${resource_name}  Modbus_DeviceValue_Boolean_R
    And Create Unavailable Modbus device
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
