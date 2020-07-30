*** Settings ***
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Default Tags  skipped

*** Variables ***
${SUITE}         Multiple Device Service


*** Keywords ***


*** Test Cases ***
MultipleDS001-Device profiles have created from several device-service
    When Start several device services at the same time
    Then Device profiles have been created for each device service
    And Value descriptors have been created for each device service

MultipleDS002-Send get command to the one of device when multiple device-service alive at the same time
    Given Start several device services at the same time
    And Create devices for each device service
    When Send get command to devices with different device service
    Then Device reading has been created for each device service

MultipleDS003-Set Locked to the one of device when multiple device-service alive at the same time
    Given Start several device services at the same time
    And Create devices for each device service
    When Send put command to locked devices with different device service
    Then Notification for updating the device has been created.

MultipleDS004-Device events/readings have been received when multiple device-service alive at the same time
    Given Start several device services at the same time
    When Create devices with autoevent for each device service
    sleep  60
    Then Device events/readings have been created for each device service

MultipleDS005-Multiple device profiles has been created for same device service
    Given Start device service
    And Create 3 device profiles for the device service
    when Create devices with autoevent and different device profiles
    sleep  60
    Then Device events/readings have been created
