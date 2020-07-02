*** Settings ***
Documentation  Device Readings - Query readings
Library   OperatingSystem
Library   Collections
Library   TAF.utils.src.setup.consul
Resource  TAF/testCaseModules/keywords/commonKeywords.robot
Resource  TAF/testCaseModules/keywords/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Suite Teardown
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token

*** Variables ***
${SUITE}                        Add Reading
${READINGS}
${TEST_DEVICE_1}                test-device-1
${TEST_DEVICE_1_VALUE_DESCRIPTOR}    test-device-1-value-descriptor
${TEST_DEVICE_1_VALUE}    123
${TEST_DEVICE_2}                test-device-2
${TEST_DEVICE_2_VALUE_DESCRIPTOR}    test-device-2-value-descriptor
${TEST_DEVICE_2_VALUE}    123

${TEST_DEVICE_3}=
...  {
...    "name" :"test-device-3","adminState":"UNLOCKED","operatingState":"ENABLED",
...    "service":{"name":"Test-Device-Service"},
...    "profile": {"name": "Test-Device-Profile"},
...    "protocols":{"other": {}}
...  }
${TEST_DEVICE_3_VALUE_DESCRIPTOR}    test-device-3-value-descriptor
${TEST_DEVICE_3_VALUE}    123

*** Keywords ***
Query readings by value descriptor and device id
    [Arguments]    ${valueDescriptor}   ${deviceId}
    ${readings}=  Query readings by value descriptor ${valueDescriptor} and device id "${deviceId}"
    Set test variable  ${READINGS}  ${readings}

Readings should contain the value descriptor and device id and value
    [Arguments]    ${valueDescriptor}   ${deviceId}   ${value}
        ${length}=  get length  ${READINGS}
    :FOR    ${reading}   IN  @{READINGS}
    \  Should contain    ${reading}[name]  ${valueDescriptor}
    \  Should contain    ${reading}[device]  ${deviceId}
    \  Should contain    ${reading}[value]  ${value}

The config MetaDataCheck set to ${boolVal}
    Modify consul config  /v1/kv/edgex/core/1.0/edgex-core-data/Writable/MetaDataCheck  ${boolVal}
    sleep  2

*** Test Cases ***
Add reading to core data srevice
    When add reading with value ${TEST_DEVICE_1_VALUE} by value descriptor ${TEST_DEVICE_1_VALUE_DESCRIPTOR} and device id ${TEST_DEVICE_1}
    Then query readings by value descriptor and device id   ${TEST_DEVICE_1_VALUE_DESCRIPTOR}  ${TEST_DEVICE_1}
    And readings should contain the value descriptor and device id and value   ${TEST_DEVICE_1_VALUE_DESCRIPTOR}  ${TEST_DEVICE_1}  ${TEST_DEVICE_1_VALUE}

Fail to add reading to core data srevice when the config MetaDataCheck set to true
    Given the config MetaDataCheck set to true
    When add reading with value ${TEST_DEVICE_2_VALUE} by value descriptor ${TEST_DEVICE_2_VALUE_DESCRIPTOR} and device id ${TEST_DEVICE_2}
    Then should return status code "400"
    [Teardown]  the config MetaDataCheck set to false

# Adding reading needs the device data when the config MetaDataCheck set to true
Success to add reading to core data srevice when the config MetaDataCheck set to true
    ${addressable}=    Create Dictionary   name=test-addressable
    ${deviceService}=    Create Dictionary   name=Test-Device-Service  adminState=UNLOCKED  operatingState=ENABLED  addressable=${addressable}
    ${deviceProfile}=    Create Dictionary   name=Test-Device-Profile
    ${device}=  evaluate  json.loads('''${TEST_DEVICE_3}''')  json
    Given the config MetaDataCheck set to true
    And create addressable ${addressable}
    And create device service ${deviceService}
    And create device profile ${deviceProfile}
    And create device with ${device}
    When add reading with value ${TEST_DEVICE_3_VALUE} by value descriptor ${TEST_DEVICE_3_VALUE_DESCRIPTOR} and device id ${device}[name]
    Then should return status code "200"
    [Teardown]  Run Keywords  the config MetaDataCheck set to false
    ...  AND  delete device by name ${device}[name]
    ...  AND  delete device profile by name ${deviceProfile}[name]
    ...  AND  delete device service by name ${deviceService}[name]
    ...  AND  delete addressable by name ${addressable}[name]
