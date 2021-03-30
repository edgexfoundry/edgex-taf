*** Settings ***
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Force Tags  Skipped

*** Variables ***
${SUITE}         Create Notification


*** Keywords ***


*** Test Cases ***
Notification should be created if adding new device
    When Create Device ${device_name}
    Then  Notification has been created

Notification should be created if device adminState has been updated
    Given Create Device
    When Update Device ${adminStateLocked}
    Then  Notification has been created

Notification should be created if device operationState has been updated
    Given Create Device
    When Update Device ${operatingStateDisabled}
    Then  Notification has been created

Notification should be created if device profile has been changed
    Given Create Device
    When Update Device ${profileChanged}
    Then  Notification has been created

Notification should be created if autoEvent has been changed
    Given Create Device
    When Update Device ${autoEventChanged}
    Then  Notification has been created

Notification should be created if deleting device
    When Delete Device ${device_name}
    Then  Notification has been created