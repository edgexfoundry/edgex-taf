*** Settings ***
Library      TAF/testCaseModules/keywords/setup/edgex.py
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource     TAF/testCaseModules/keywords/common/metrics.robot
Suite Setup  Run keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                   AND  Set Telemetry Interval to ${interval}s For ${APP_SERVICE_NAME} On Registry Service
...                   AND  Update Service Configuration  /${APP_SERVICE_NAME}/Writable/LogLevel  DEBUG
...                   AND  Restart Services  ${APP_SERVICE_NAME}
Suite Teardown  Run keywords  Terminate All Processes
...                      AND  Delete all events by age
...                      AND  Set Telemetry Interval to 30s For ${APP_SERVICE_NAME} On Registry Service
...                      AND  Restart Services  ${APP_SERVICE_NAME}
...                      AND  Run Teardown Keywords

*** Variables ***
${SUITE}          APP Services Metrics Test - MQTT bus
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app_services_metrics_mqtt.log
${interval}       4
${interval_ex}    8
${INT8_CMD}       ${PREFIX}_GenerateDeviceValue_INT8_RW
${INT16_CMD}      ${PREFIX}_GenerateDeviceValue_INT16_RW
${FLOAT32_CMD}    ${PREFIX}_GenerateDeviceValue_FLOAT32_RW
@{COMMANDS}       ${INT8_CMD}  ${INT16_CMD}  ${FLOAT32_CMD}
@{APP_METRICS}    HttpExportSize  MqttExportSize  MessagesReceived  InvalidMessagesReceived
           ...    PipelineMessagesProcessed  PipelineMessageProcessingTime  PipelineProcessingErrors

*** Test Cases ***
APPServicesMetricsMQTT001-No Telemery Metrics isn't Published to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/${APP_SERVICE_NAME}/#  payload
    And Set Test Variable  ${device_name}  telemetry-metrics
    And Set All Telemetry Metrics To False
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${INT8_CMD} with ds-pushevent=true
    And Sleep  ${interval}
    Then No Telemetry Metrics are Received
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

APPServicesMetricsMQTT002-Enable HttpExportSize And Verify Metrics is Publish to MessageBus
    ${handle_http}  Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True   # Start HTTP Server
    Sleep  1s  # Waiting for Http Server startup
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/${APP_SERVICE_NAME}/HttpExportSize  payload  2
    And Set Test Variable  ${device_name}  http-export-size
    And Set ${APP_SERVICE_NAME} Functions HTTPExport
    And Set Telemetry Metrics/HttpExportSize to true For ${APP_SERVICE_NAME} On Registry Service
    And Restart Services  ${APP_SERVICE_NAME}
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${INT8_CMD} with ds-pushevent=true
    And Sleep  ${interval}
    Then Metrics HttpExportSize With histogram-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_http}  kill=True
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set Telemetry Metrics/HttpExportSize to false For ${APP_SERVICE_NAME} On Registry Service
                ...      AND  Set ${APP_SERVICE_NAME} Functions FilterByProfileName, FilterByDeviceName, FilterByResourceName, TransformXml, SetResponseData
                ...      AND  Restart Services  ${APP_SERVICE_NAME}

APPServicesMetricsMQTT003-Enable MqttExportSize And Verify Metrics is Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/${APP_SERVICE_NAME}/MqttExportSize  payload  2
    And Set Test Variable  ${device_name}  mqtt-export-size
    And Set ${APP_SERVICE_NAME} Functions MQTTExport
    And Set Telemetry Metrics/MqttExportSize to true For ${APP_SERVICE_NAME} On Registry Service
    And Restart Services  ${APP_SERVICE_NAME}
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${INT8_CMD} with ds-pushevent=true
    And Sleep  ${interval}
    Then Metrics MqttExportSize With histogram-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set Telemetry Metrics/MqttExportSize to false For ${APP_SERVICE_NAME} On Registry Service
                ...      AND  Set ${APP_SERVICE_NAME} Functions FilterByProfileName, FilterByDeviceName, FilterByResourceName, TransformXml, SetResponseData
                ...      AND  Restart Services  ${APP_SERVICE_NAME}

APPServicesMetricsMQTT004-Enable MessagesReceived And Verify Metrics is Publish to MessageBus
    Given Set Test Variable  ${device_name}  message-received
    And Set ${APP_SERVICE_NAME} Functions SetResponseData
    And Set Telemetry Metrics/MessagesReceived to true For ${APP_SERVICE_NAME} On Registry Service
    And Restart Services  ${APP_SERVICE_NAME}
    And Run MQTT Subscriber Progress And Output  edgex/telemetry/${APP_SERVICE_NAME}/MessagesReceived  payload  2
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${INT8_CMD} with ds-pushevent=true
    And Sleep  ${interval}
    Then Metrics MessagesReceived With counter-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set Telemetry Metrics/MessagesReceived to false For ${APP_SERVICE_NAME} On Registry Service
                ...      AND  Restart Services  ${APP_SERVICE_NAME}

APPServicesMetricsMQTT005-Enable InvalidMessagesReceived And Verify Metrics is Publish to MessageBus
    ${publish_msg}  Set Variable  Invalid Message
    Given Set Test Variable  ${device_name}  invalid-message-received
    And Set ${APP_SERVICE_NAME} Functions SetResponseData
    And Create Device For device-virtual With Name ${device_name}
    And Set Telemetry Metrics/InvalidMessagesReceived to true For ${APP_SERVICE_NAME} On Registry Service
    And Run MQTT Subscriber Progress And Output  edgex/telemetry/${APP_SERVICE_NAME}/InvalidMessagesReceived  payload  2
    When Run process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-publisher.py edgex/events/${device_name} "${publish_msg}" ${BROKER_PORT} ${SECURITY_SERVICE_NEEDED}
         ...          shell=True  timeout=10s
    And Sleep  ${interval_ex}
    Then Metrics InvalidMessagesReceived With counter-count Should Be Received
    [Teardown]  Run keywords  Terminate Process  ${handle_mqtt}  kill=True   # Stop MQTT Subscribe Process
                ...      AND  Set Telemetry Metrics/InvalidMessagesReceived to false For ${APP_SERVICE_NAME} On Registry Service
                ...      AND  Restart Services  ${APP_SERVICE_NAME}

APPServicesMetricsMQTT006-Enable PipelineMessagesProcessed And Verify Metrics is Publish to MessageBus
    Given Set Test Variable  ${device_name}  pipeline-messages-processed
    And Set ${APP_SERVICE_NAME} Functions SetResponseData
    And Set Topics For ${APP_SERVICE_NAME} PerTopicPipelines On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    And Set Telemetry Metrics/PipelineMessagesProcessed to true For ${APP_SERVICE_NAME} On Registry Service
    And Restart Services  ${APP_SERVICE_NAME}
    And Run MQTT Subscriber Progress And Output  edgex/telemetry/${APP_SERVICE_NAME}/PipelineMessagesProcessed  payload  6
    When Get Multiple Device Data With Commands ${COMMANDS}
    And Sleep  ${interval_ex}
    Then Received Metrics PipelineMessagesProcessed For All Pipelines And counter-count Should Not Be 0
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set Telemetry Metrics/PipelineMessagesProcessed to false For ${APP_SERVICE_NAME} On Registry Service
                ...      AND  Restart Services  ${APP_SERVICE_NAME}

APPServicesMetricsMQTT007-Enable PipelineMessageProcessingTime And Verify Metrics is Publish to MessageBus
    Given Set Test Variable  ${device_name}  pipeline-messages-processing-time
    And Set ${APP_SERVICE_NAME} Functions SetResponseData
    And Set Topics For ${APP_SERVICE_NAME} PerTopicPipelines On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    And Set Telemetry Metrics/PipelineMessageProcessingTime to true For ${APP_SERVICE_NAME} On Registry Service
    And Restart Services  ${APP_SERVICE_NAME}
    And Run MQTT Subscriber Progress And Output  edgex/telemetry/${APP_SERVICE_NAME}/PipelineMessageProcessingTime  payload  6
    When Get Multiple Device Data With Commands ${COMMANDS}
    And Sleep  ${interval_ex}
    Then Received Metrics PipelineMessageProcessingTime For All Pipelines And timer-count Should Not Be 0
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set Telemetry Metrics/PipelineMessageProcessingTime to false For ${APP_SERVICE_NAME} On Registry Service
                ...      AND  Restart Services  ${APP_SERVICE_NAME}

APPServicesMetricsMQTT008-Enable PipelineProcessingErrors And Verify Metrics is Publish to MessageBus
    Given Set Test Variable  ${device_name}  pipeline-processing-errors
    And Set ${APP_SERVICE_NAME} Functions HTTPExport
    And Set PerTopicPipelines float ExecutionOrder HTTPExport
    And Set PerTopicPipelines int8-16 ExecutionOrder HTTPExport
    And Set Topics For ${APP_SERVICE_NAME} PerTopicPipelines On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    And Set Telemetry Metrics/PipelineProcessingErrors to true For ${APP_SERVICE_NAME} On Registry Service
    And Restart Services  ${APP_SERVICE_NAME}
    And Run MQTT Subscriber Progress And Output  edgex/telemetry/${APP_SERVICE_NAME}/PipelineProcessingErrors  payload  6
    When Get Multiple Device Data With Commands ${COMMANDS}
    And Sleep  ${interval_ex}
    Then Received Metrics PipelineProcessingErrors For All Pipelines And counter-count Should Not Be 0
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set Telemetry Metrics/PipelineProcessingErrors to false For ${APP_SERVICE_NAME} On Registry Service
                ...      AND  Set ${APP_SERVICE_NAME} Functions FilterByProfileName, FilterByDeviceName, FilterByResourceName, TransformXml, SetResponseData
                ...      AND  Set PerTopicPipelines float ExecutionOrder TransformJson, SetResponseData
                ...      AND  Set PerTopicPipelines int8-16 ExecutionOrder TransformXml, Compress, SetResponseData
                ...      AND  Restart Services  ${APP_SERVICE_NAME}

*** Keywords ***
Set All Telemetry Metrics To False
    ${range}  Get Length  ${APP_METRICS}
    FOR  ${INDEX}  IN RANGE  ${range}
        Set Telemetry Metrics/${APP_METRICS}[${INDEX}] to false For ${APP_SERVICE_NAME} On Registry Service
    END

Get Multiple Device Data With Commands ${commands}
    ${range}  Get Length  ${commands}
    FOR  ${INDEX}  IN RANGE  ${range}
        Get device data by device ${device_name} and command ${commands}[${INDEX}] with ds-pushevent=true
    END
    sleep  500ms

No Telemetry Metrics are Received
    ${range}  Get Length  ${APP_METRICS}
    FOR  ${INDEX}  IN RANGE  ${range}
        No Metrics With Name ${APP_METRICS}[${INDEX}] Received
    END
