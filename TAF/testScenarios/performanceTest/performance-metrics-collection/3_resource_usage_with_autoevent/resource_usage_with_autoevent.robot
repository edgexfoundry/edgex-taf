*** Settings ***
Documentation   Get CPU and Memory Usage when autoevent is sending from device-virtual
Library         TAF/testCaseModules/keywords/setup/edgex.py
Library         TAF/testCaseModules/keywords/performance-metrics-collection/RetrieveResourceUsage.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup     Setup Suite

*** Variables ***
${SUITE}          Get CPU and Memory Usage while sending autoevent
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/performance-metric-collection-resource-usage.log

*** Test Cases ***
Resource001 - Get CPU and Memory Usage while sending autoevent
    Deploy EdgeX  -  PerformanceMetrics
    ${CPU_MEM_USAGE_LIST}=  Retrieve CPU and memory usage and loop "${GET_CPU_MEM_LOOP_TIMES}" times per "${ GET_CPU_MEM_INTERVAL}"s
    ${cpu_usage}=  retrieve cpu aggregation value  ${CPU_MEM_USAGE_LIST}
    ${mem_usage}=  retrieve mem aggregation value  ${CPU_MEM_USAGE_LIST}
    Show the summary table  ${CPU_MEM_USAGE_LIST}
    Show the cpu aggregation table  ${cpu_usage}
    Show the mem aggregation table  ${mem_usage}
    [Teardown]  Shutdown services

*** Keywords ***
Retrieve CPU and memory usage and loop "${GET_CPU_MEM_LOOP_TIMES}" times per "${ GET_CPU_MEM_INTERVAL}"s
    @{CPU_MEM_USAGE_LIST}=  Create List
    sleep  30
    FOR  ${index}  IN RANGE  0  ${GET_CPU_MEM_LOOP_TIMES}
        sleep  ${ GET_CPU_MEM_INTERVAL}
        ${resource_usage}=  Retrieve CPU and memory usage
        Run keyword and continue on failure  CPU usage is over than threshold setting
        Run keyword and continue on failure  Memory usage is over than threshold setting
        Append to list  ${CPU_MEM_USAGE_LIST}  ${resource_usage}
    END
    [Return]   ${CPU_MEM_USAGE_LIST}

