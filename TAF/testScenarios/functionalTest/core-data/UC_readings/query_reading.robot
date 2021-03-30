*** Settings ***
Documentation  Device Readings - Query readings
Library   OperatingSystem
Library   Collections
Resource  TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Suite Teardown
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags  Skipped

*** Variables ***
${SUITE}                                  Query Readings
${READINGS}
${DEVICE_ID_TEST_DEVICE_1}                test-device-1
${VALUE_DESCRIPTOR_TEST_DEVICE_1_VAL1}    test-device-1-val



*** Keywords ***
core-data has ${amount} readings with value descriptor ${valueDescriptor} and device id ${deviceId}
    FOR    ${INDEX}    IN RANGE  ${amount}
       run keyword and continue on failure  add reading with value ${INDEX} by value descriptor ${valueDescriptor} and device id "${deviceId}"
    END

Query readings by value descriptor and device id
    [Arguments]    ${valueDescriptor}   ${deviceId}
    ${readings}=  Query readings by value descriptor ${valueDescriptor} and device id "${deviceId}"
    set suite variable  ${READINGS}  ${readings}

Readings should order by created in descending order
    # Compare the created date to check the reading order
    ${length}=  get length  ${READINGS}
    FOR    ${index}   IN RANGE  0  ${length}-1
       Should Be True  ${READINGS}[${index}][created] > ${READINGS}[${index+1}][created]
    END

Readings should contain the value descriptor and device id
    [Arguments]    ${valueDescriptor}   ${deviceId}
        ${length}=  get length  ${READINGS}
    FOR    ${reading}   IN  @{READINGS}
       Should contain      ${reading}[name]  ${valueDescriptor}
       Should contain      ${reading}[device]  ${deviceId}
    END

*** Test Cases ***
Query readings by device name and value descriptor
    Given core-data has 2 readings with value descriptor ${VALUE_DESCRIPTOR_TEST_DEVICE_1_VAL1} and device id ${DEVICE_ID_TEST_DEVICE_1}
    When Query readings by value descriptor and device id   ${VALUE_DESCRIPTOR_TEST_DEVICE_1_VAL1}  ${DEVICE_ID_TEST_DEVICE_1}
    Then Readings should order by created in descending order
    And Readings should contain the value descriptor and device id  ${VALUE_DESCRIPTOR_TEST_DEVICE_1_VAL1}  ${DEVICE_ID_TEST_DEVICE_1}