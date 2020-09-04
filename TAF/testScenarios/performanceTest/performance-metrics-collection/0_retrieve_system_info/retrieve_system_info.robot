*** Settings ***
Library  TAF/testCaseModules/keywords/performance-metrics-collection/RetrieveSystemInfo.py


*** Test Cases ***
Get System Info
    fetch system info
    generate system report
