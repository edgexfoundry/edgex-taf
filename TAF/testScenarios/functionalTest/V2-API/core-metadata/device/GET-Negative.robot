*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device GET Negative Test Cases

*** Test Cases ***
ErrDeviceGET001 - Query device by non-existent device name
    When Query Device By Name
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrDeviceGET002 - Check device exists by non-existent device name
    When Check Device Exists By Name
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrDeviceGET003 - Query devices with empty device profile name
    Given Create Device Profile
    When Query All Devices With Specified Profile
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profile

ErrDeviceGET004 - Query all devices with empty device service name
    Given Create Device Service
    When Query All Devices With Specified Device Service
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Services

ErrDeviceGET005 - Query all devices with non-int value on offset/limit
    Given Create Devices
    When Query All Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
