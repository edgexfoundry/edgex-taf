*** Settings ***
Library      uuid
Library      json
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${RES_TOPIC}        edgex/command/response/#
${QUERY_RES_TOPIC}  edgex/commandquery/response


*** Keywords ***
Query Commands For ${device} From External MQTT Broker
    ${uuid}  Evaluate  str(uuid.uuid4())
    Set Test Variable  ${requestId}  ${uuid}
    ${topic_suffix}  Run Keyword If  "${device}" == "All Devices"  Set Variable  all
                     ...       ELSE  Set Variable  ${device_name}
    ${topic}  Set Variable  edgex/commandquery/request/${topic_suffix}
    ${message_dict}  Load data file "core-command/north_south_messaging.json" and get variable "QUERY"
    Set To Dictionary  ${message_dict}  apiVersion=${API_VERSION}
    Set To Dictionary  ${message_dict}  requestId=${requestId}
    Remove From Dictionary  ${message_dict}  queryParams
    ${message_str}  Convert To String  ${message_dict}
    ${message}  Replace String  ${message_str}  '  "
    Run process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-publisher.py ${topic} '${message}' ${EX_BROKER_PORT} false
    ...          shell=True

Query All Devices Commands With ${parameter}=${value} From External MQTT Broker
    ${uuid}  Evaluate  str(uuid.uuid4())
    Set Test Variable  ${requestId}  ${uuid}
    ${topic}  Set Variable  edgex/commandquery/request/all
    ${message_dict}  Load data file "core-command/north_south_messaging.json" and get variable "QUERY"
    Set To Dictionary  ${message_dict}  apiVersion=${API_VERSION}
    Set To Dictionary  ${message_dict}  requestId=${requestId}
    Set To Dictionary  ${message_dict}[queryParams]  ${parameter}=${value}
    ${message_str}  Convert To String  ${message_dict}
    ${message}  Replace String  ${message_str}  '  "
    Run process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-publisher.py ${topic} '${message}' ${EX_BROKER_PORT} false
    ...          shell=True

Get Command From External MQTT Broker
    ${uuid}=  Evaluate  str(uuid.uuid4())
    Set Test Variable  ${requestId}  ${uuid}
    ${topic}  Set Variable  edgex/command/request/${device_name}/${resource_name}/get
    ${message_dict}  Load data file "core-command/north_south_messaging.json" and get variable "GET"
    Set To Dictionary  ${message_dict}  apiVersion=${API_VERSION}
    Set To Dictionary  ${message_dict}  requestId=${requestId}
    Remove From Dictionary  ${message_dict}  queryParams
    ${message_str}  Convert To String  ${message_dict}
    ${message}  Replace String  ${message_str}  '  "
    Run process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-publisher.py ${topic} '${message}' ${EX_BROKER_PORT} false
    ...          shell=True

Get Command With ${parameter}=${value} From External MQTT Broker
    ${uuid}  Evaluate  str(uuid.uuid4())
    Set Test Variable  ${requestId}  ${uuid}
    ${topic}  Set Variable  edgex/command/request/${device_name}/${resource_name}/get
    ${message_dict}  Load data file "core-command/north_south_messaging.json" and get variable "GET"
    Set To Dictionary  ${message_dict}  apiVersion=${API_VERSION}
    Set To Dictionary  ${message_dict}  requestId=${requestId}
    Set To Dictionary  ${message_dict}[queryParams]  ${parameter}=${value}
    ${message_str}  Convert To String  ${message_dict}
    ${message}  Replace String  ${message_str}  '  "
    Run process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-publisher.py ${topic} '${message}' ${EX_BROKER_PORT} false
    ...          shell=True

Set Command From External MQTT Broker
    ${uuid}  Evaluate  str(uuid.uuid4())
    Set Test Variable  ${requestId}  ${uuid}
    ${payload}  Encode Request Body ${reading_name}=${reading_value} To Base64
    ${topic}  Set Variable  edgex/command/request/${device_name}/${resource_name}/set
    ${message_dict}  Load data file "core-command/north_south_messaging.json" and get variable "SET"
    Set To Dictionary  ${message_dict}  apiVersion=${API_VERSION}
    Set To Dictionary  ${message_dict}  requestId=${requestId}
    Set To Dictionary  ${message_dict}  payload=${payload}
    ${message_str}  Convert To String  ${message_dict}
    ${message}  Replace String  ${message_str}  '  "
    Run process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-publisher.py ${topic} '${message}' ${EX_BROKER_PORT} false
    ...          shell=True

Should Return Error Code 0 And Response Payload With GET Command Should Be Correct
    ${last_msg}  Get Response Message
    ${last_msg_json}  Evaluate  json.loads('''${last_msg}''')
    Should Be Equal As Strings  edgex/command/response/${device_name}/${resource_name}/get  ${last_msg_json}[receivedTopic]
    Should Be Equal As Integers  0  ${last_msg_json}[errorCode]
    Should Be Equal  ${requestId}  ${last_msg_json}[requestID]
    # Validate Payload Content
    ${payload}  Decode Base64 String  ${last_msg}
    Should Be Equal As Strings  ${device_name}  ${payload}[event][deviceName]
    Should Be Equal As Strings  ${resource_name}  ${payload}[event][sourceName]
    Should Not Be Empty  ${payload}[event][readings][0][value]

Should Return Error Code 0 And Response Payload With SET Command Should Be Correct
    ${last_msg}  Get Response Message
    ${last_msg_json}  Evaluate  json.loads('''${last_msg}''')
    Should Be Equal As Strings  edgex/command/response/${device_name}/${resource_name}/set  ${last_msg_json}[receivedTopic]
    Should Be Equal  ${requestId}  ${last_msg_json}[requestID]
    Should Be Equal As Integers  0  ${last_msg_json}[errorCode]
    Should Be Equal As Strings  None  ${last_msg_json}[payload]

Should Return Error Code 1 And RequestID Should Be The Same As Request
    ${last_msg}  Get Response Message
    ${last_msg_json}  Evaluate  json.loads('''${last_msg}''')
    Should Be Equal  ${requestId}  ${last_msg_json}[requestID]
    Should Be Equal As Integers  1  ${last_msg_json}[errorCode]

Get Response Message
    Wait Until Keyword Succeeds  10x  2s  File Should Not Be Empty  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}
    ${content}  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}  payload
    ${count}  Get Line Count  ${content}
    ${last_msg}  Run Keyword If  ${count} > 1  Get Line  ${content}  -1
                 ...       ELSE  Set Variable  ${content}
    [Return]  ${last_msg}

Set Random Read Command
    @{data_type_skip_write_only}  Get All Read Commands
    ${random_command}  Get random "commandName" from "${data_type_skip_write_only}"
    Set Test Variable  ${resource_name}  ${random_command}

Set Random Write Command
    @{data_type_skip_read_only}  Get All Write Commands
    ${random_command}  Get random "commandName" from "${data_type_skip_read_only}"
    Set Test Variable  ${resource_name}  ${random_command}

Encode Request Body ${key}=${value} To Base64
    ${req_dict}  Create Dictionary  ${key}=${value}
    ${req_json}  Evaluate  json.dumps(${req_dict})
    ${payload}  Evaluate  base64.b64encode(bytes('${req_json}', 'UTF-8'))  modules=base64
    ${payload}  Decode Bytes To String  ${payload}  UTF-8
    [Return]  ${payload}
