*** Settings ***
Library      TAF/testCaseModules/keywords/setup/edgex.py
Resource     TAF/testCaseModules/keywords/common/metrics.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run keywords  Setup Suite
...                   AND  Set Suite Variable  ${interval}  2
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                   AND  Set Telemetry Interval to ${interval}s For ${TEST_SERVICE} On Registry Service
Suite Teardown  Run keywords  Terminate All Processes
...                      AND  Delete all events by age
...                      AND  Set Telemetry Interval to 30s For ${TEST_SERVICE} On Registry Service
...                      AND  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Data Metrics Test - MQTT bus
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_data_metrics_mqtt.log
${TEST_SERVICE}  core-data


*** Test Cases ***
DataMetricsMQTT001-Enable EventsPersisted And Verify Metrics is Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/${TEST_SERVICE}/EventsPersisted  payload  2
    And Set Test Variable  ${device_name}  events-persisted-true
    And Set Telemetry Metrics/EventsPersisted to true For ${TEST_SERVICE} On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then Metrics EventsPersisted With counter-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set Telemetry Metrics/EventsPersisted to false For ${TEST_SERVICE} On Registry Service

DataMetricsMQTT002-Disable EventsPersisted And Verify Metrics isn't Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/${TEST_SERVICE}/EventsPersisted  payload  2
    And Set Test Variable  ${device_name}  events-persisted-false
    And Set Telemetry Metrics/EventsPersisted to false For ${TEST_SERVICE} On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then No Metrics With Name EventsPersisted Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

DataMetricsMQTT003-Enable ReadingsPersisted And Verify Metrics is Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/${TEST_SERVICE}/ReadingsPersisted  payload  2
    And Set Test Variable  ${device_name}  readings-persisted-true
    And Set Telemetry Metrics/ReadingsPersisted to true For ${TEST_SERVICE} On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then Metrics ReadingsPersisted With counter-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set Telemetry Metrics/ReadingsPersisted to false For ${TEST_SERVICE} On Registry Service

DataMetricsMQTT004-Disable ReadingsPersisted And Verify Metrics isn't Publish to MessageBus
    Given Run MQTT Subscriber Progress And Output  edgex/telemetry/${TEST_SERVICE}/ReadingsPersisted  payload  2
    And Set Test Variable  ${device_name}  readings-persisted-false
    And Set Telemetry Metrics/ReadingsPersisted to false For ${TEST_SERVICE} On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then No Metrics With Name ReadingsPersisted Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
