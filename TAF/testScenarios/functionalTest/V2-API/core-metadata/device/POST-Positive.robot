*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device POST Test Cases


*** Test Cases ***
DevicePOST001 - Create device with same device service
    When Create Multiple Device
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "1200"ms

DevicePOST002 - Create device with different device service
    When Create Multiple Device
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "1200"ms

DevicePOST003 - Create device with uuid
    # Request body contains uuid
    When Create Multiple Device
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Returned UUID Should Be The Same As Assigned
    And Response Time Should Be Less Than "1200"ms
