*** Settings ***
Suite Setup     Deploy EdgeX
Suite Teardown  Shutdown EdgeX

*** Test Cases ***
Device_TC0001 - adminState is LOCKED
    [Tags]  Skipped
    Given adminState of DS is "LOCKED"
    When ${response} = Send GET request "${path_ping}" to "${host_ds}"
    Then Status code in "${response}" should be "423"

Device_TC0002 - operatingState is DISABLED
    [Tags]  Skipped
    Given operatingState of device "${device_name}" is "DISABLED"
    When ${response} = Get "${resource}" reading from device "${device_name}"
    Then Status code in "${response}" should be "423"