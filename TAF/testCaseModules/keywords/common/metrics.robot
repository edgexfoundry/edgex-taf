*** Settings ***
Library      RequestsLibrary
Library      OperatingSystem
Library      Collections
Library      String
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot

*** Variables ***
${APP_SERVICE_NAME}  app-sample

*** Keywords ***
Set Telemetry ${config} to ${value} For ${service_name} On Registry Service
    ${telemetry_path}  Set Variable  /${service_name}/Writable/Telemetry
    ${path}  Set Variable   ${telemetry_path}/${config}
    Update Service Configuration  ${path}  ${value}

Set Topics For ${APP_SERVICE_NAME} PerTopicPipelines On Registry Service
    ${perTopics}  Create List  float  int8-16
    ${path}  Set Variable  /${APP_SERVICE_NAME}/Writable/Pipeline/PerTopicPipelines
    FOR  ${ITEM}  IN  @{perTopics}
        ${topics_path}  Set Variable  ${path}/${ITEM}/Topics
        Update Service Configuration  ${topics_path}  events/device/+/+/${device_name}/#
    END

Metrics ${metrics_name} With ${field_name} Should Be Received
    Wait Until Keyword Succeeds  10x  1s  File Should Not Be Empty  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}
    ${content}  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}  payload
    ${count}  Get Line Count  ${content}
    ${last_msg}  Run Keyword If  ${count} > 1  Get Line  ${content}  -1
                 ...       ELSE  Set Variable  ${content}
    ${last_msg_json}  Evaluate  json.loads('''${last_msg}''')
    ${payload}  Set Variable  ${last_msg_json}[payload]
    Log  ${payload}
    Should Be Equal As Strings  ${metrics_name}  ${payload}[name]
    Should Contain  str(${payload})  ${field_name}
    # Validate event is calculated
    FOR  ${INDEX}  IN RANGE  len(${payload}[fields])
        Run Keyword If  '${payload}[fields][${INDEX}][name]' == '${field_name}'  Run Keywords
        ...             Should Not Be Equal As Integers  0  ${payload}[fields][${INDEX}][value]
        ...        AND  Exit For Loop
    END

Received Metrics ${metrics_name} For All Pipelines And ${field_name} Should Not Be 0
    Wait Until Keyword Succeeds  10x  1s  File Should Not Be Empty  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}
    @{pipeline_ids}  Create List  default-pipeline  float-pipeline  int8-16-pipeline
    @{message_ids}  Create List
    ${content}  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}  payload
    ${messages}  Split String  ${content}  \n
    # Set same pipeline messages to a list
    @{decode_default_pipe}  Create List
    @{decode_int_pipe}  Create List
    @{decode_float_pipe}  Create List
    FOR  ${msg}  IN  @{messages}
        ${msg_json}  Evaluate  json.loads('''${msg}''')
        ${msg_payload}  Set Variable  ${msg_json}[payload]
        Run Keyword If  "default-pipeline" in """${msg_payload}"""  Append To List  ${decode_default_pipe}  ${msg_payload}
        ...     ELSE IF  "int8-16-pipeline" in """${msg_payload}"""  Append To List  ${decode_int_pipe}  ${msg_payload}
        ...     ELSE IF  "float-pipeline" in """${msg_payload}"""  Append To List  ${decode_float_pipe}  ${msg_payload}
    END

    # Validate value from the last pipeline message
    @{all_pipe}  Create List  ${decode_default_pipe}  ${decode_int_pipe}  ${decode_float_pipe}
    FOR  ${pipe}  IN  @{all_pipe}
        ${metrics}  Get From List  ${pipe}  -1
        Should Be Equal As Strings  ${metrics_name}  ${metrics}[name]
        FOR  ${INDEX}  IN RANGE  len(${metrics}[tags])
            Run Keyword If  '${metrics}[tags][${INDEX}][name]' == 'pipeline'  Run Keywords
            ...              Append To List  ${message_ids}  ${metrics}[tags][${INDEX}][value]
            ...         AND  Exit For Loop
        END
        # Validate count value
        FOR  ${INDEX}  IN RANGE  len(${metrics}[fields])
            Run Keyword If  '${metrics}[fields][${INDEX}][name]' == '${field_name}'  Run Keywords
            ...             Run Keyword And Continue On Failure  Should Not Be Equal As Integers  0  ${metrics}[fields][${INDEX}][value]
            ...        AND  Exit For Loop
        END
    END
    Lists Should Be Equal  ${pipeline_ids}  ${message_ids}  ignore_order=True

No Metrics With Name ${metrics_name} Received
    ${file_size}  Get File Size  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}
    Run Keyword If  ${file_size} == 0  Log  No Any Metrics Received With The Topic
    ...       ELSE  No ${metrics_name} Found In File

No ${metrics_name} Found In File
    ${content}  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/${subscriber_file}  payload
    Log  ${content}
    ${count}  Get Line Count  ${content}
    FOR  ${INDEX}  IN RANGE  ${count}
        ${json_msg}  Get Line  ${content}  ${INDEX}
        ${encode_payload}  Evaluate  json.loads('''${json_msg}''')
        ${payload}  Evaluate  json.loads('''${decode_payload}''')
        Should Not Be Equal As Strings  ${metrics_name}  ${payload}[name]
    END
    Log  No ${metrics_name} Received In MessageBus With The Topic

Get First Lines
    [Arguments]  ${string}  ${lines}
    ${list}  Create List
    FOR  ${INDEX}  IN RANGE  ${lines}
        ${line}  Get Line  ${string}  ${INDEX}
        Append To List  ${list}  ${line}
    END
    RETURN  ${list}

Set PerTopicPipelines ${perTopicPipeline} ExecutionOrder ${functions}
    ${path}=  Set variable  /${APP_SERVICE_NAME}/Writable/Pipeline/PerTopicPipelines/${perTopicPipeline}/ExecutionOrder
    Update Service Configuration  ${path}  ${functions}
