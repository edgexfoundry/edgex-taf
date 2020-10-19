*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device PATCH Testcases


*** Test Cases ***
DevicePATCH001 - Update device
    # name, operatingState, adminState, labels, protocols
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "1200"ms

DevicePATCH002 - Update device with device service and profile
    # profileName, serviceName
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "1200"ms
