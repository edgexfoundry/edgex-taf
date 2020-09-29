*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Service PATCH Positive Test Cases


*** Test Cases ***
DevicePATCH001 - Update device services
    # name, operatingState, adminState, labels, protocols
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "1200"ms

DevicePATCH002 - Update device with device service and profile
    # device service and profile
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "1200"ms
