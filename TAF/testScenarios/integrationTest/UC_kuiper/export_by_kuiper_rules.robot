*** Settings ***
Library          BuiltIn
Library          Process
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                             AND  Create A Stream With Edgex Type
Suite Teardown   Run Keywords   Delete Stream
...                             AND  Delete all events by age
...                             AND  Run Teardown Keywords
Force Tags       MessageBus=redis  MessageBus=MQTT

*** Variables ***
${SUITE}         Export By Kuiper Rules
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/export_by_kuiper_rules.log
${kuiperUrl}     ${URI_SCHEME}://${BASE_URL}:${RULESENGINE_PORT}

*** Test Cases ***
Kuiper001 - Add a new rule and export to MQTT
    ${rule_sql}  Set Variable  SELECT * FROM ${stream}
    Given Set Test Variable  ${device_name}  kuiper-mqtt-device
    And Set Test Variable  ${command}  ${PREFIX}_GenerateDeviceValue_INT8_RW
    And Set Test Variable  ${resource}  ${PREFIX}_DeviceValue_INT8_RW
    And Run MQTT Subscriber Progress And Output  rules-events-kuiper  ${resource}  1  ${EX_BROKER_PORT}  false  30
    Given Create A Rule mqtt-rule With ${rule_sql} And MQTT Sink
    And Create Device For device-virtual With Name ${device_name}
    When Execute Get Command ${command} To Trigger ${device_name}
    Then Device data with keyword "${resource}" has recevied by mqtt subscriber
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Delete Rules mqtt-rule
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

Kuiper002 - Add a new rule to execute set command
    [Setup]  Skip if  $SECURITY_SERVICE_NEEDED == 'true'  # Wait until ekuiper support JWT call
    ${random_int8}  Evaluate  random.randint(-128, 128)  random
    ${random_int8_str}  Convert To String  ${random_int8}
    ${resource}  Set Variable  ${PREFIX}_DeviceValue_INT8_RW
    ${rule_sql_0}  Set Variable  SELECT * FROM ${stream} WHERE ${resource}>=0
    ${rule_sql_1}  Set Variable  SELECT * FROM ${stream} WHERE ${resource}<0
    Given Set Test Variable  ${device_name}  kuiper-edgex-device
    And Set Test Variable  ${kuiper_set_resource}  Virtual_DeviceValue_INT16_RW
    And Set Test Variable  ${resource_value}  ${random_int8}
    And Create A Rule rest-rule-0 With ${rule_sql_0} And REST Sink
    And Create A Rule rest-rule-1 With ${rule_sql_1} And REST Sink
    And Create Device For device-virtual With Name ${device_name}
    When Set Device Data By Device ${device_name} And Command ${PREFIX}_GenerateDeviceValue_INT8_RW With ${resource}:${random_int8_str}
    And Execute Get Command ${PREFIX}_GenerateDeviceValue_INT8_RW To Trigger ${device_name}
    And Execute Get Command ${kuiper_set_resource} To Trigger ${device_name}
    Then Resource Value Should Be Updated
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Delete Rules rest-rule-0
                ...      AND  Delete Rules rest-rule-1

*** Keywords ***
Create A Stream With Edgex Type
    Set Suite Variable  ${stream}  edgexsource
    Create Session  Kuiper  url=${kuiperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${json_data}  Get File  ${WORK_DIR}/TAF/testData/kuiper/stream.json  encoding=UTF-8
    ${json_data}  Replace String  ${json_data}  %stream%  ${stream}
    ${sql}  Evaluate  json.loads(r'''${json_data}''')  json
    ${resp}  POST On Session  Kuiper    /streams  json=${sql}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  log to console  ${content}

Create A Rule ${rule_id} With ${rule_sql} And ${action} Sink
    Create Session  Kuiper  url=${kuiperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${action_data}  Set ${action} Action Value With Rule ${rule_id}
    ${rule_data}  Get File  ${WORK_DIR}/TAF/testData/kuiper/rule.json  encoding=UTF-8
    ${rule}  Evaluate  json.loads(r'''${rule_data}''')  json
    Set to dictionary  ${rule}  id=${rule_id}
    Set to Dictionary  ${rule}  sql=${rule_sql}
    Set to Dictionary  ${rule}  actions=${action_data}
    ${resp}  POST On Session  Kuiper    /rules  json=${rule}  headers=${headers}  expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  log to console  ${content}

Set ${action} Action Value With Rule ${rule_id}
    ${action_data}  Load data file "kuiper/action.json" and get variable "${action}"
    ${url}  Set Variable  http://edgex-core-command:59882/api/v2/device/name/${device_name}/Virtual_GenerateDeviceValue_INT16_RW
    Run Keyword If  '${action}' == 'REST' and '${rule_id}' == 'rest-rule-0'  Run Keywords
    ...              Set to dictionary  ${action_data}[0][rest]  url=${url}
    ...              AND  Set to dictionary  ${action_data}[0][rest]  dataTemplate={\"${kuiper_set_resource}\":\"123\"}
    ...    ELSE IF  '${action}' == 'REST' and '${rule_id}' == 'rest-rule-1'  Run Keywords
    ...              Set to dictionary  ${action_data}[0][rest]  url=${url}
    ...              AND  Set to dictionary  ${action_data}[0][rest]  dataTemplate={\"${kuiper_set_resource}\":\"-123\"}
    Run Keyword If  '${action}' == 'MQTT'
    ...      Set to dictionary  ${action_data}[0][mqtt]  server=tcp://edgex-taf-mqtt-broker:${BROKER_PORT}
    [Return]  ${action_data}

Execute Get Command ${command} To Trigger ${device_name}
    Invoke Get command with params ds-pushevent=true by device ${device_name} and command ${command}
    Should return status code "200"
    sleep  500ms

Set Device Data By Device ${device_name} And Command ${command} With ${resource}:${value}
    Invoke Set command by device ${deviceName} and command ${command} with request body ${resource}:${value}
    Should return status code "200"
    sleep  500ms

Delete Rules ${rules_id}
    Create Session  Kuiper  url=${kuiperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}  DELETE On Session  Kuiper  /rules/${rules_id}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}

Delete Stream
    Create Session  Kuiper  url=${kuiperUrl}  disable_warnings=true
    ${headers}  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}  DELETE On Session  Kuiper  /streams/${stream}  headers=${headers}
    ...       expected_status=any
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}

Device data with keyword "${keyword}" has recevied by mqtt subscriber
    Dump Last 100 lines Log And Service Config  app-rules-engine  http://localhost:59701
    ${mqtt_broker_received}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}  ${keyword}
    run keyword if  """${mqtt_broker_received}""" == '${EMPTY}'
    ...             fail  No export log found on mqtt subscriber
    ...       ELSE  Log  Found export data: ${mqtt_broker_received}

Resource Value Should Be Updated
    ${get_reading_value}  Set Variable  ${content}[event][readings][0][value]
    Run Keyword If  ${resource_value} >= 0  Should Be Equal  ${get_reading_value}  123
    ...       ELSE   Should Be Equal  ${get_reading_value}  -123
