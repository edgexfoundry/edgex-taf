*** Settings ***
Library      TAF/testCaseModules/keywords/setup/edgex.py
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run keywords  Setup Suite
...                   AND  Set Suite Variable  ${interval}  2
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                   AND  Set Telemetry Interval=${interval}s For core-data On Consul
Suite Teardown  Run keywords  Terminate All Processes
...                      AND  Delete all events by age
...                      AND  Set Telemetry Interval=30s For core-data On Consul
...                      AND  Run Teardown Keywords
Force Tags      MessageQueue=MQTT

*** Variables ***
${SUITE}          Core Data Metrics Test - MQTT bus
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_data_metrics_mqtt.log


*** Test Cases ***
DataMetricsMQTT001-Enable EventsPersisted And Verify Metrics is Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/core-data/EventsPersisted  Payload
    And Set Test Variable  ${device_name}  events-persisted-true
    And Set Telemetry Metrics/EventsPersisted=true For core-data On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then Metrics EventsPersisted Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Set Telemetry Metrics/EventsPersisted=false For core-data On Consul

DataMetricsMQTT002-Disable EventsPersisted And Verify Metrics isn't Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/core-data/EventsPersisted  Payload
    And Set Test Variable  ${device_name}  events-persisted-false
    And Set Telemetry Metrics/EventsPersisted=false For core-data On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then No Metrics With Name EventsPersisted Received
    [Teardown]  Delete device by name ${device_name}

DataMetricsMQTT003-Enable ReadingsPersisted And Verify Metrics is Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/core-data/ReadingsPersisted  Payload
    And Set Test Variable  ${device_name}  readings-persisted-true
    And Set Telemetry Metrics/ReadingsPersisted=true For core-data On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then Metrics ReadingsPersisted Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Set Telemetry Metrics/ReadingsPersisted=false For core-data On Consul

DataMetricsMQTT004-Disable ReadingsPersisted And Verify Metrics isn't Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/core-data/ReadingsPersisted  Payload
    And Set Test Variable  ${device_name}  readings-persisted-false
    And Set Telemetry Metrics/ReadingsPersisted=false For core-data On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then No Metrics With Name ReadingsPersisted Received
    [Teardown]  Delete device by name ${device_name}

