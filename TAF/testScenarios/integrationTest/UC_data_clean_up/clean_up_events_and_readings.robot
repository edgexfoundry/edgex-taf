*** Settings ***
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot
Default Tags  skipped

*** Variables ***
${SUITE}         Clean Up Events/Readings By Scheduler


*** Keywords ***


*** Test Cases ***
Scheduler001-Set scheduler for each 30s to clean up events
    Given Create Interval and set frequency to "30s"
    When Create interval action with delete events for core-data
    sleep  30
    Then All events have been deleted

Scheduler002-Set scheduler for each 60s to clean up events
    Given Create Interval and set frequency to "60s"
    When Create interval action with delete events for core-data
    sleep  60
    Then All events have been deleted

