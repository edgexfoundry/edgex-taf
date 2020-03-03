*** Settings ***
Documentation  Device Readings - Query readings
Library   OperatingSystem
Library   Collections
Resource  TAF/testCaseModules/keywords/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/coreDataAPI.robot



*** Variables ***
${SUITE}                                  Add Reading
${READINGS}
${DEVICE_ADD_READING}                device-add-reading
${DEVICE_ADD_READING_VALUE_DESCRIPTOR}    device-add-reading-value-descriptor
${DEVICE_ADD_READING_VALUE}    123



*** Keywords ***
Query readings by value descriptor and device id
    [Arguments]    ${valueDescriptor}   ${deviceId}
    ${readings}=  Query readings by value descriptor ${valueDescriptor} and device id "${deviceId}"
    set suite variable  ${READINGS}  ${readings}

Readings should contain the value descriptor and device id and value
    [Arguments]    ${valueDescriptor}   ${deviceId}   ${value}
        ${length}=  get length  ${READINGS}
    :FOR    ${reading}   IN  @{READINGS}
    \  Should contain      ${reading}[name]  ${valueDescriptor}
    \  Should contain      ${reading}[device]  ${deviceId}
    \  Should contain      ${reading}[value]  ${value}

*** Test Cases ***
Add reading to core data srevice
    When add reading with value ${DEVICE_ADD_READING_VALUE} by value descriptor ${DEVICE_ADD_READING_VALUE_DESCRIPTOR} and device id ${DEVICE_ADD_READING}
    Then query readings by value descriptor and device id   ${DEVICE_ADD_READING_VALUE_DESCRIPTOR}  ${DEVICE_ADD_READING}
    And readings should contain the value descriptor and device id and value   ${DEVICE_ADD_READING_VALUE_DESCRIPTOR}  ${DEVICE_ADD_READING}  ${DEVICE_ADD_READING_VALUE}