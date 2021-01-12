*** Settings ***
Documentation   Measure the event exported time
Library         TAF/testCaseModules/keywords/setup/edgex.py
Library         TAF/testCaseModules/keywords/performance-metrics-collection/EventExportedTime.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup     Run Keywords    Setup Suite


*** Variables ***
${SUITE}          Get events exported time
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/performance-metric-collection-exported-time.log

*** Test Cases ***
Measure the event exported time
    Given Deploy EdgeX  -  PerformanceMetrics  -mqtt
    When Retrieve Events From Subscriber
    And fetch the exported time
    Then Run keyword and continue on failure  exported time is less than threshold value
    And show the summary table
    And show the aggregation table
    [Teardown]  Shutdown services  -  PerformanceMetrics  -mqtt

*** Keywords ***



