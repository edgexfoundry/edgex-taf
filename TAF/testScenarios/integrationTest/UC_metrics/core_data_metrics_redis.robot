*** Settings ***
Library      TAF/testCaseModules/keywords/setup/edgex.py
Resource     TAF/testCaseModules/keywords/common/metrics.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run keywords  Setup Suite
...                   AND  Set Suite Variable  ${interval}  2
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                   AND  Set Telemetry Interval=${interval}s For ${TEST_SERVICE} On Registry Service
Suite Teardown  Run keywords  Terminate All Processes
...                      AND  Delete all events by age
...                      AND  Set Telemetry Interval=30s For ${TEST_SERVICE} On Registry Service
...                      AND  Run Teardown Keywords
Force Tags      MessageBus=redis  backward-skip

*** Variables ***
${SUITE}          Core Data Metrics Test - Redis Bus
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_data_metrics_redis.log
${TEST_SERVICE}  core-data


*** Test Cases ***
DataMetricsRedis001-Enable EventsPersisted And Verify Metrics is Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.${TEST_SERVICE}.EventsPersisted  telemetry
    And Set Test Variable  ${device_name}  events-persisted-true
    And Set Telemetry Metrics/EventsPersisted=true For ${TEST_SERVICE} On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then Metrics EventsPersisted With counter-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/EventsPersisted=false For ${TEST_SERVICE} On Registry Service

DataMetricsRedis002-Disable EventsPersisted And Verify Metrics isn't Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.${TEST_SERVICE}.EventsPersisted  telemetry
    And Set Test Variable  ${device_name}  events-persisted-false
    And Set Telemetry Metrics/EventsPersisted=false For ${TEST_SERVICE} On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then No Metrics With Name EventsPersisted Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True

DataMetricsRedis003-Enable ReadingsPersisted And Verify Metrics is Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.${TEST_SERVICE}.ReadingsPersisted  telemetry
    And Set Test Variable  ${device_name}  readings-persisted-true
    And Set Telemetry Metrics/ReadingsPersisted=true For ${TEST_SERVICE} On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then Metrics ReadingsPersisted With counter-count Should Be Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True
                ...      AND  Set Telemetry Metrics/ReadingsPersisted=false For ${TEST_SERVICE} On Registry Service

DataMetricsRedis004-Disable ReadingsPersisted And Verify Metrics isn't Publish to MessageBus
    Given Run Redis Subscriber Progress And Output  edgex.telemetry.${TEST_SERVICE}.ReadingsPersisted  telemetry
    And Set Test Variable  ${device_name}  readings-persisted-false
    And Set Telemetry Metrics/ReadingsPersisted=false For ${TEST_SERVICE} On Registry Service
    And Create Device For device-virtual With Name ${device_name}
    When Create multiple events
    And Sleep  ${interval}
    Then No Metrics With Name ReadingsPersisted Received
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Terminate Process  ${handle_redis}  kill=True
