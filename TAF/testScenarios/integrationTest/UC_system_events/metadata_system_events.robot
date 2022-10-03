*** Settings ***
Force Tags     Skipped

*** Variables ***
${SUITE}          Core-Metadata System Events Test - MQTT bus
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/metadata_system_events.log

*** Test Cases ***
SystemEvents001-Create Device and Receive Correct System Events
    Given Create A Device Profile
    And Create A Device
    When Subscribe Mosquitto With Topic
    Then System Events Should Match With Specified Source and Type and Action

SystemEvents002-Create Multiple Devices and Receive Correct System Events
    Given Create A Device Profile
    And Create Multiple Devices
    When Subscribe Mosquitto With Topic
    Then System Events Should Match With Specified Source and Type and Action

SystemEvents003-Update Multiple Devices and Receive Correct System Events
    Given Create A Device Profile
    And Create Multiple Devices
    And Update Multiple Devices
    When Subscribe Mosquitto With Topic
    Then System Events Should Match With Specified Source and Type and Action

SystemEvents004-Delete Device and Receive Correct System Events
    Given Create A Device Profile
    And Create A Device
    And Delete A Device
    When Subscribe Mosquitto With Topic
    Then System Events Should Match With Specified Source and Type and Action
