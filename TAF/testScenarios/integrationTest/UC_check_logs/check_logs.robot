*** Settings ***
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot

*** Variables ***
${SUITE}         Verify Service logs


*** Keywords ***


*** Test Cases ***
Logging001- Get core-metadata Error logs by support-logging
    Given Update "core-metadata" loglevel to "Error" from consul
    And Create duplicate device
    When Query support-logging with loglevel "Error" for core-metadata
    Then Create device logs have been generated

Logging002- Get core-data Debug logs by support-logging
    Given Update "core-data" loglevel to "Debug" from consul
    And Create events
    When Query support-logging with loglevel "Debug" for core-data
    Then Create events logs have been generated

Logging003- Get core-command Debug logs by support-logging
    Given Update "core-command" loglevel to "Debug" from consul
    And Send commands to device
    When Query support-logging with loglevel "Info" for core-command
    Then Send command logs have been generated

Logging004- Get support-notifications Trace logs by support-logging
    Given Update "support-notifications" loglevel to "Trace" from consul
    And Create device
    When Query support-logging with loglevel "Trace" for support-notifications
    Then Create notifications logs have been found
    And Notification has been created

Logging005- Get support-scheduler Warn logs by support-logging
    Given Update "support-scheduler" loglevel to "Warn" from consul
    And Create scheduler for delete events
    When Query support-logging with loglevel "Warn" for support-scheduler
    Then Clean up events logs have been generated

Logging006- Get device-virtual Trace logs by support-logging
    Given Update "device-virtual" loglevel to "Trace" from consul
    And Create device
    When Query support-logging with loglevel "Trace" for the device-virtual
    Then Create devices logs have been generated for the device-virtual
