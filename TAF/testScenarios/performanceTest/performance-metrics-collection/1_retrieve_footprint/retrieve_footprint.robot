*** Settings ***
Documentation   Get image and binary footprint and compare size with prior release
...             Image Footprint:            Get docker image footprint of each edgex services
...             Executable Footprint:	    Copy service executable file from container to host and get the executable footprint of each edgex services
Library         TAF/testCaseModules/keywords/setup/edgex.py
Library         TAF/testCaseModules/keywords/performance-metrics-collection/RetrieveFootprint.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup     Setup Suite

*** Variables ***
${SUITE}          Get Image and Binary Footprint
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/performance-metric-collection-retrieve-footprint.log

*** Test Cases ***
Footprint001 - Verify Image and Binary Footprint
    Given Deploy EdgeX  -  PerformanceMetrics
    When Fetch image binary footprint
    Then Show the summary table
    And Run keyword and continue on failure  Image footprint is less than threshold value
    And Run keyword and continue on failure  Binary footprint is less than threshold value
    [Teardown]  Shutdown services
