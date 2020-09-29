*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device GET Positive Test Cases

*** Test Cases ***
DeviceGET007 - Query all devices with specified device profile by profile name
    Given Create Multiple Devices With Several Profiles
    When Query All Devices With Specified Profile
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Devices Should Be Linked To Specified Profile
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET008 - Query all devices with specified device profile by profile name and offset
    Given Create Multiple Devices With Several Profiles
    When Query All Devices With Specified Profile
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Devices Should Be Linked To Specified Profile
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET009 - Query all devices with specified device profile by profile name and limit
    Given Create Multiple Devices With Several Profiles
    When Query All Devices With Specified Profile
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Devices Should Be Linked To Specified Profile
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET010 - Query all devices with specified device service by service name
    Given Create Multiple Devices With Several Device Services
    When Query All Devices With Specified Device Service
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Devices Should Be Linked To Specified Device Service
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET011 - Query all devices with specified device service by service name and offset
    Given Create Multiple Devices With Several Device Services
    When Query All Devices With Specified Device Service
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Devices Should Be Linked To Specified Device Service
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices

DeviceGET012 - Query all devices with specified device service by service name and limit
    Given Create Multiple Devices With Several Device Services
    When Query All Devices With Specified Device Service
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Devices Should Be Linked To Specified Device Service
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Devices
