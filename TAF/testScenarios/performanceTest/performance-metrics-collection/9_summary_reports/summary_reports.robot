*** Settings ***
Documentation   Show performance summary reports
Library         TAF/testCaseModules/keywords/performance-metrics-collection/PerformanceSummaryReports.py

*** Test Cases ***
Show performance summary reports
    Show reports  ${startup_time_with_create_container_aggregation_list}
    ...           ${startup_time_without_create_container_aggregation_list}
