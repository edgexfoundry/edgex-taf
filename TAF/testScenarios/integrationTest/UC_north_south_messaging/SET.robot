*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource        TAF/testCaseModules/keywords/core-command/externalSystem.robot
Suite Setup  Run keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      MessageBus=MQTT  MessageBus=redis  backward-skip

*** Variables ***
${SUITE}          North-South Messaging Set Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/north-south-messaging-set.log

*** Test Cases ***
NSMessagingSET001 - Set specified device write command
    Given Set Test Variable  ${device_name}  ex_mqtt_set
    And Get A Write Command
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  payload  1  ${EX_BROKER_PORT}  false
    When Set Command From External MQTT Broker
    Then Should Return Error Code 0 And Response Payload With SET Command Should Be Correct
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingSET001 - Set specified device write command with non-existent device
    Given Set Test Variable  ${device_name}  ex-mqtt-set-non-existent-device
    And Get A Write Command
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  payload  1  ${EX_BROKER_PORT}  false
    When Set Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingSET002 - Set specified device write command with non-existent command
    Given Set Test Variable  ${device_name}  ex-mqtt-set-invalid-command
    And Get A Write Command
    And Set Test Variable  ${resource_name}  invalid
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  payload  1  ${EX_BROKER_PORT}  false
    When Set Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

ErrNSMessagingSET002 - Set specified device write command when device is locked
    Given Set Test Variable  ${device_name}  ex-mqtt-set-locked-device
    And Get A Write Command
    And Create Device For device-virtual With Name ${device_name}
    And Update Device ${device_name} With adminState=LOCKED
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  payload  1  ${EX_BROKER_PORT}  false
    When Set Command From External MQTT Broker
    Then Should Return Error Code 1 And RequestID Should Be The Same As Request
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

*** Keywords ***
Get A Write Command
    @{data_types_all_write}  Get All Write Commands
    ${data_type}  set variable  ${data_types_all_write}[0][dataType]
    ${command}  set variable  ${data_types_all_write}[0][commandName]
    ${reading_name}  set variable  ${data_types_all_write}[0][readingName]
    ${random_value}  Get reading value with data type "${data_type}"
    ${reading_value}  convert to string  ${random_value}
    Set Test Variable  ${resource_name}  ${command}
    Set Test Variable  ${reading_name}  ${reading_name}
    Set Test Variable  ${reading_value}  ${reading_value}
