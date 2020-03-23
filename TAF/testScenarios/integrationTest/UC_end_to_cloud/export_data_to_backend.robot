*** Settings ***
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot

*** Variables ***
${SUITE}         Export data to backend


*** Keywords ***


*** Test Cases ***
Export001 - Export events/readings to HTTP Server
    Given Deploy device service
    And Deploy configurable application service with http-export profile
    And Create device
    When Retrieve device data by get command from the device
    Then Reading have exported to HTTP Server
    And The exported reading existed on core-data and mark as Pushed
    And Related log found on core-data
    And Related log found on configurable application service

Export002 - Export events/readings to MQTT Server
    Given Deploy device service
    And Start MQTT Server
    And Deploy configurable application service with mqtt-export profile
    And Create device
    When Retrieve device data by get command from the device
    Then Reading have exported to MQTT Server
    And The exported reading existed on core-data and mark as Pushed
    And Related log found on core-data
    And Related log found on configurable application service

ExportErr001 - Export events/readings to unreachable HTTP backend
    Given Deploy device service
    And Deploy configurable application service with unreachable http backend
    And Create device
    When Retrieve device data by get command from the device
    Then The exported data existed on core-data and doesn't mark as Pushed
    And Related logs found on core-data
    And Related logs found on configurable application service

ExportErr002 - Export events/readings to unreachable MQTT backend
    Given Deploy device service
    And Deploy configurable application service with unreachable mqtt backend
    And Create device
    When Retrieve device data by get command from the device
    Then The exported data existed on core-data and doesn't mark as Pushed
    And Related logs found on core-data
    And Related logs found on configurable application service
