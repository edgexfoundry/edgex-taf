*** Settings ***
Documentation   Measure the startup time for starting all services at once
...             Get service start up time with creating containers
...             Get service start up time without creating containers
Library         Process
Library         TAF/testCaseModules/keywords/setup/edgex.py
Library         TAF/testCaseModules/keywords/performance-metrics-collection/ServiceStartupTime.py
Library         TAF/testCaseModules/keywords/performance-metrics-collection/StartupTimeHandler.py
Library         TAF/testCaseModules/keywords/setup/startup_checker.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup     Setup Suite

*** Variables ***
${SUITE}          Measure services startup time and get max, min, and average
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/performance-metric-services-startup-time.log
${clear_mem_cache}   sync; echo 3 | tee /proc/sys/vm/drop_caches

*** Test Cases ***
StartupTime001 - Get service startup time with creating containers
    ${total_startup_time_list}  ${services_startup_time_list}=  Deploy edgex with creating containers and get startup time
    ${startup_time_with_create_container_aggregation_list}=  Get avg max min values  ${total_startup_time_list}
    startup time is less than threshold setting  ${total_startup_time_list}
    show full startup time report  Full startup time with creating containers  ${services_startup_time_list}
    show startup time with creating container avg max min  ${startup_time_with_create_container_aggregation_list}
    set global variable  ${startup_time_with_create_container}  ${startup_time_with_create_container_aggregation_list}
    [Teardown]  run keyword if test failed  set global variable  ${startup_time_with_create_container}  None

StartupTime002 - Get service startup time without creating containers
    [Setup]  Run keywords   Deploy EdgeX  -  PerformanceMetrics
             ...            AND  Stop services
    ${total_startup_time_list}  ${services_startup_time_list}=  Deploy edgex without creating containers and get startup time
    ${startup_time_without_create_container_aggregation_list}=  Get avg max min values  ${total_startup_time_list}
    startup time is less than threshold setting  ${total_startup_time_list}
    show full startup time report  Full startup time without creating containers  ${services_startup_time_list}
    show startup time without creating container avg max min   ${startup_time_without_create_container_aggregation_list}
    set global variable  ${startup_time_without_create_container}  ${startup_time_without_create_container_aggregation_list}
    [Teardown]  Run Keywords  Shutdown services
                ...           AND  run keyword if test failed  set global variable  ${startup_time_without_create_container}  None


*** Keywords ***
Deploy edgex with creating containers and get startup time
    @{total_startup_time_list}=  Create List
    @{service_startup_time_list}=  Create List
    FOR  ${index}    IN RANGE  0  ${STARTUP_TIME_LOOP_TIME}
        ${result}=  Run Process  ${clear_mem_cache}  shell=True
                    ...          stdout=${WORK_DIR}/TAF/testArtifacts/logs/clear_mem.log
        Start time is recorded
        Deploy EdgeX  -  PerformanceMetrics
        ${services_startup_time}=  fetch services startup time
        Shutdown services
        Append to list  ${service_startup_time_list}  ${services_startup_time}
        ${total_startup_time}=  convert to number  ${services_startup_time}[Total startup time][startupTime]
        Append to list  ${total_startup_time_list}    ${total_startup_time}
        Check service is stopped or not
    END
    [Return]  ${total_startup_time_list}  ${service_startup_time_list}

Deploy edgex without creating containers and get startup time
    @{total_startup_time_list}=  Create List
    @{service_startup_time_list}=  Create List
    FOR  ${index}    IN RANGE  0  ${STARTUP_TIME_LOOP_TIME}
        ${result}=  Run Process  ${clear_mem_cache}  shell=True
                    ...          stdout=${WORK_DIR}/TAF/testArtifacts/logs/clear_mem_cache.log
        Start time is recorded
        Deploy EdgeX  -  PerformanceMetrics
        ${services_startup_time}=  fetch services startup time without creating containers
        Stop services
        Append to list  ${service_startup_time_list}  ${services_startup_time}
        ${total_startup_time}=  convert to number  ${services_startup_time}[Total startup time][startupTime]
        Append to list  ${total_startup_time_list}    ${total_startup_time}
        Check service is stopped or not
    END
    [Return]  ${total_startup_time_list}  ${service_startup_time_list}
