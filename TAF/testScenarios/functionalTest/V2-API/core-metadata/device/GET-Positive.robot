*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device GET Positive Test Cases

*** Test Cases ***
DeviceGET001 - Query all devices
    Given Create Multiple Devices
    When Query All Devices
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET002 - Query all devices with offset
    Given Create Multiple Devices
    When Query All Devices
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET003 - Query all devices with limit
    Given Create Multiple Devices
    When Query All Devices
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET004 - Query all devices with specified labels
    Given Create Multiple Devices
    When Query All Devices
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Devices Should Be Linked To Specified Label
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET005 - Query device by name
    Given Create A Device
    When Query Device By Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET006 - Check device exists by name
    Given Create A Device
    When Check Device Exists By Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices
