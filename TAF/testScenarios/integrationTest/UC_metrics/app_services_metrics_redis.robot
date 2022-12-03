*** Settings ***
Library      TAF/testCaseModules/keywords/setup/edgex.py
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource     TAF/testCaseModules/keywords/common/metrics.robot
Suite Setup  Run keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                   AND  Set Telemetry Interval=${interval}s For app-sample On Consul
...                   AND  Update Service Configuration On Consul  ${CONSUL_CONFIG_BASE_ENDPOINT}/app-sample/Writable/LogLevel  DEBUG
Suite Teardown  Run keywords  Terminate All Processes
...                      AND  Delete all events by age
...                      AND  Set Telemetry Interval=30s For app-sample On Consul
...                      AND  Run Teardown Keywords
Force Tags      backward-skip  MessageQueue=redis

*** Variables ***
${SUITE}          APP Services Metrics Test - Redis bus
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app_services_metrics_redis.log
${interval}       4
${interval_ex}    8
${INT8_CMD}       ${PREFIX}_GenerateDeviceValue_INT8_RW
${INT16_CMD}      ${PREFIX}_GenerateDeviceValue_INT16_RW
${FLOAT32_CMD}    ${PREFIX}_GenerateDeviceValue_FLOAT32_RW
@{COMMANDS}       ${INT8_CMD}  ${INT16_CMD}  ${FLOAT32_CMD}
@{APP_METRICS}    HttpExportSize  MqttExportSize  MessagesReceived  InvalidMessagesReceived
           ...    PipelineMessagesProcessed  PipelineMessageProcessingTime  PipelineProcessingErrors

*** Test Cases ***
APPServicesMetricsRedis001-No Telemery Metrics isn't Published to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.app-sample.#  telemetry
    And Set Test Variable  ${device_name}  telemetry-metrics
    And Set All Telemetry Metrics To False
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${INT8_CMD} with ds-pushevent=yes
    And Sleep  ${interval}
    Then No Telemetry Metrics are Received
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True

APPServicesMetricsRedis002-Enable HttpExportSize And Verify Metrics is Publish to MessageBus
    ${handle_http}  Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True   # Start HTTP Server
    Sleep  1s  # Waiting for Http Server startup
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.app-sample.HttpExportSize  telemetry
    And Set Test Variable  ${device_name}  http-export-size
    And Set app-sample Functions HTTPExport
    And Set Telemetry Metrics/HttpExportSize=true For app-sample On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${INT8_CMD} with ds-pushevent=yes
    And Sleep  ${interval}
    Then Metrics HttpExportSize With histogram-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_http}  kill=True
                ...      AND  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/HttpExportSize=false For app-sample On Consul
                ...      AND  Set app-sample Functions FilterByProfileName, FilterByDeviceName, FilterByResourceName, TransformXml, SetResponseData

APPServicesMetricsRedis003-Enable MqttExportSize And Verify Metrics is Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.app-sample.MqttExportSize  telemetry
    And Set Test Variable  ${device_name}  mqtt-export-size
    And Set app-sample Functions MQTTExport
    And Set Telemetry Metrics/MqttExportSize=true For app-sample On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${INT8_CMD} with ds-pushevent=yes
    And Sleep  ${interval}
    Then Metrics MqttExportSize With histogram-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/MqttExportSize=false For app-sample On Consul
                ...      AND  Set app-sample Functions FilterByProfileName, FilterByDeviceName, FilterByResourceName, TransformXml, SetResponseData

APPServicesMetricsRedis004-Enable MessagesReceived And Verify Metrics is Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.app-sample.MessagesReceived  telemetry
    And Set Test Variable  ${device_name}  message-received
    And Set Telemetry Metrics/MessagesReceived=true For app-sample On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${INT8_CMD} with ds-pushevent=yes
    And Sleep  ${interval}
    Then Metrics MessagesReceived With counter-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/MessagesReceived=false For app-sample On Consul

APPServicesMetricsRedis005-Enable InvalidMessagesReceived And Verify Metrics is Publish to MessageBus
    ${publish_msg}  Set Variable  Invalid Message
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.app-sample.InvalidMessagesReceived  telemetry  2
    And Set Test Variable  ${device_name}  invalid-message-received
    And Create Device For device-virtual With Name ${device_name}
    And Set Telemetry Metrics/InvalidMessagesReceived=true For app-sample On Consul
    When Run process  python ${WORK_DIR}/TAF/utils/src/setup/redis-publisher.py edgex.events.${device_name} "${publish_msg}" ${SECURITY_SERVICE_NEEDED}
         ...          shell=True
    And Sleep  ${interval_ex}
    Then Metrics InvalidMessagesReceived With counter-count Should Be Received
    [Teardown]  Run keywords  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/InvalidMessagesReceived=false For app-sample On Consul

APPServicesMetricsRedis006-Enable PipelineMessagesProcessed And Verify Metrics is Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.app-sample.PipelineMessagesProcessed  telemetry  6
    And Set Test Variable  ${device_name}  pipeline-messages-processed
    And Set Topics For app-samle PerTopicPipelines On Consul
    And Set Telemetry Metrics/PipelineMessagesProcessed=true For app-sample On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get Multiple Device Data With Commands ${COMMANDS}
    And Sleep  ${interval_ex}
    Then Recieved Metrics PipelineMessagesProcessed For All Pipelines And timer-count Should Not Be 0
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/PipelineMessagesProcessed=false For app-sample On Consul

APPServicesMetricsRedis007-Enable PipelineMessageProcessingTime And Verify Metrics is Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.app-sample.PipelineMessageProcessingTime  telemetry  6
    And Set Test Variable  ${device_name}  pipeline-messages-processing-time
    And Set Topics For app-samle PerTopicPipelines On Consul
    And Create Device For device-virtual With Name ${device_name}
    And Set Telemetry Metrics/PipelineMessageProcessingTime=true For app-sample On Consul
    When Get Multiple Device Data With Commands ${COMMANDS}
    And Sleep  ${interval_ex}
    Then Recieved Metrics PipelineMessageProcessingTime For All Pipelines And timer-count Should Not Be 0
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/PipelineMessageProcessingTime=false For app-sample On Consul

APPServicesMetricsRedis008-Enable PipelineProcessingErrors And Verify Metrics is Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.app-sample.PipelineProcessingErrors  telemetry  6
    And Set Test Variable  ${device_name}  pipeline-processing-errors
    And Set app-sample Functions HTTPExport
    And Set PerTopicPipelines float ExecutionOrder HTTPExport
    And Set PerTopicPipelines int8-16 ExecutionOrder HTTPExport
    And Set Topics For app-samle PerTopicPipelines On Consul
    And Set Telemetry Metrics/PipelineProcessingErrors=true For app-sample On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get Multiple Device Data With Commands ${COMMANDS}
    And Sleep  ${interval_ex}
    Then Recieved Metrics PipelineProcessingErrors For All Pipelines And counter-count Should Not Be 0
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/PipelineProcessingErrors=false For app-sample On Consul
                ...      AND  Set app-sample Functions FilterByProfileName, FilterByDeviceName, FilterByResourceName, TransformXml, SetResponseData
                ...      AND  Set PerTopicPipelines float ExecutionOrder TransformJson, SetResponseData
                ...      AND  Set PerTopicPipelines int8-16 ExecutionOrder TransformXml, Compress, SetResponseData

*** Keywords ***
Set All Telemetry Metrics To False
    ${range}  Get Length  ${APP_METRICS}
    FOR  ${INDEX}  IN RANGE  ${range}
        Set Telemetry Metrics/${APP_METRICS}[${INDEX}]=false For app-sample On Consul
    END

Get Multiple Device Data With Commands ${commands}
    ${range}  Get Length  ${commands}
    FOR  ${INDEX}  IN RANGE  ${range}
        Get device data by device ${device_name} and command ${commands}[${INDEX}] with ds-pushevent=yes
    END
    sleep  500ms

No Telemetry Metrics are Received
    ${range}  Get Length  ${APP_METRICS}
    FOR  ${INDEX}  IN RANGE  ${range}
        No Metrics With Name ${APP_METRICS}[${INDEX}] Received
    END
