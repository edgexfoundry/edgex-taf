*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource        TAF/testCaseModules/keywords/core-command/externalSystem.robot
Suite Setup  Run keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      MessageQueue=MQTT  MessageQueue=redis  backward-skip

*** Variables ***
${SUITE}          North-South Messaging GET Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/north-south-messaging-get-positive.log

*** Test Cases ***
NSMessagingGET001 - Query all DeviceCoreCommands
    Given Create 3 Devices For device-virtual
    And Run MQTT Subscriber Progress And Output  ${QUERY_RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Query Commands For All Devices From External MQTT Broker
    Then Should Return Error Code 0 And Commands For All Devices Should Be Also Returned
    [Teardown]  Run keywords  Delete multiple devices by names  @{device_list}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

NSMessagingGET002 - Query all DeviceCoreCommands by offset
    Given Create 3 Devices For device-virtual
    And Run MQTT Subscriber Progress And Output  ${QUERY_RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Query All Devices Commands With offset=1 From External MQTT Broker
    Then Should Return Error Code 0 And Commands With Filter offset=1 Should Be Also Returned
    [Teardown]  Run keywords  Delete multiple devices by names  @{device_list}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

NSMessagingGET003 - Query all DeviceCoreCommands by limit
    Given Create 3 Devices For device-virtual
    And Run MQTT Subscriber Progress And Output  ${QUERY_RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Query All Devices Commands With limit=3 From External MQTT Broker
    Then Should Return Error Code 0 And Commands With Filter limit=3 Should Be Also Returned
    [Teardown]  Run keywords  Delete multiple devices by names  @{device_list}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

NSMessagingGET004 - Query DeviceCoreCommand by device name
    Given Set Test Variable  ${device_name}  ex-mqtt-query-device
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${QUERY_RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Query Commands For Specified Device From External MQTT Broker
    Then Should Return Error Code 0 And Commands Should Be Also Returned
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

NSMessagingGET005 - Get specified device read command
    [Tags]  SmokeTest
    Given Set Test Variable  ${device_name}  ex-mqtt-get
    And Set Random Read Command
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command From External MQTT Broker
    Then Should Return Error Code 0 And Response Payload With GET Command Should Be Correct
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

NSMessagingGET006 - Get specified device read command when ds-returnevent is no
    Given Set Test Variable  ${device_name}  ex-mqtt-get-returnevent
    And Set Random Read Command
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command With ds-returnevent=no From External MQTT Broker
    Then Should Return Error Code 0 And Response Payload With GET Command Should Be Null
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

NSMessagingGET007 - Get specified device read command when ds-pushevent is yes
    Given Set Test Variable  ${device_name}  ex-mqtt-get-pushevent
    And Set Random Read Command
    And Create Device For device-virtual With Name ${device_name}
    And Run MQTT Subscriber Progress And Output  ${RES_TOPIC}  Payload  1  ${EX_BROKER_PORT}  false
    When Get Command With ds-pushevent=yes From External MQTT Broker
    Then Should Return Error Code 0 And Response Payload With GET Command Should Be Correct
    And Event Has Been Pushed To Core Data
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

*** Keywords ***
Should Return Error Code 0 And Response Payload With GET Command Should Be Null
    ${last_msg}  Get Response Message
    ${last_msg_json}  Evaluate  json.loads('''${last_msg}''')
    Should Be Equal As Integers  0  ${last_msg_json}[ErrorCode]
    Should Be Equal As Strings  None  ${last_msg_json}[Payload]

Should Return Error Code 0 And Commands For All Devices Should Be Also Returned
    # Response for Query Command
    ${last_msg}  Get Response Message
    ${last_msg_json}  Evaluate  json.loads('''${last_msg}''')
    Should Be Equal As Integers  0  ${last_msg_json}[ErrorCode]
    ${payload}  Decode Base64 String  ${last_msg}
    ${devices_list}  Get deviceCoreCommands Devices List From ${payload}
    # Retrieve devices by core-command API
    Query All DeviceCoreCommands
    ${api_devices_list}  Get deviceCoreCommands Devices List From ${content}
    Lists Should Be Equal  ${api_devices_list}  ${devices_list}

Should Return Error Code 0 And Commands With Filter ${param}=${value} Should Be Also Returned
    # Response for Query Command with parameters
    ${last_msg}  Get Response Message
    ${last_msg_json}  Evaluate  json.loads('''${last_msg}''')
    Should Be Equal As Integers  0  ${last_msg_json}[ErrorCode]
    ${payload}  Decode Base64 String  ${last_msg}
    ${devices_list}  Get deviceCoreCommands Devices List From ${payload}
    # Retrieve devices by core-command API
    Query all deviceCoreCommands with ${param}=${value}
    ${api_devices_list}  Get deviceCoreCommands Devices List From ${content}
    Lists Should Be Equal  ${api_devices_list}  ${devices_list}

Should Return Error Code 0 And Commands Should Be Also Returned
    ${last_msg}  Get Response Message
    ${last_msg_json}  Evaluate  json.loads('''${last_msg}''')
    Should Be Equal As Integers  0  ${last_msg_json}[ErrorCode]
    ${payload}  Decode Base64 String  ${last_msg}
    Should Be Equal As Strings  ${device_name}  ${payload}[deviceCoreCommand][deviceName]
    Should Not Be Empty  ${payload}[deviceCoreCommand][coreCommands]

Get deviceCoreCommands Devices List From ${string}
    #${data_json}  Evaluate  json.loads('''${string}''')
    ${data_json}  Set Variable  ${string}
    ${devices_list}  Create List
    FOR  ${INDEX}  IN RANGE  len(${data_json}[deviceCoreCommands])
        Append To List  ${devices_list}  ${data_json}[deviceCoreCommands][${INDEX}][deviceName]
    END
    [Return]  ${devices_list}

