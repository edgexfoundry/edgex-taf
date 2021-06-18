*** Settings ***
Documentation   Measure the event exported time
Library         TAF/testCaseModules/keywords/setup/edgex.py
Library         TAF/testCaseModules/keywords/performance-metrics-collection/EventExportedTime.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Suite Setup     Setup Suite


*** Variables ***
${SUITE}          Get events exported time
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/performance-metric-collection-exported-time.log

*** Test Cases ***
Measure the event exported time
    Given Deploy EdgeX  PerformanceMetrics  -mqtt
    And Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Store Secret With MQTT Export To Vault
    When Retrieve Events From Subscriber
    And fetch the exported time
    Then Run keyword and continue on failure  exported time is less than threshold value
    And show the summary table
    And show the aggregation table
    [Teardown]  Run Keyword And Ignore Error  Shutdown services  PerformanceMetrics  -mqtt


*** Keywords ***
Store Secret With MQTT Export To Vault
    Set Test Variable  ${url}  http://${BASE_URL}:${APP_MQTT_EXPORT_PORT}
    Store Secret Data With MQTT Export Auth
