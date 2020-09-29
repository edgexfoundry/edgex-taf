*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Service PATCH Negative Test Cases


*** Test Cases ***
ErrDevicePATCH001 - Update device with use duplicate device service name
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "409"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCHValidate001 - Update device with service name validate error
    # Empty service name
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCHValidate002 - Update device with baseAddress validate error
    # Empty baseAddress
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCHValidate003 - Update device with adminState validate error
    # Empty adminState
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCHValidate004 - Update device with adminState value validate error
    # Out of optional value for adminState
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCHValidate005 - Update device with operatingState validate error
    # Empty operatingState
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCHValidate006 - Update device with operatingState validate error
    # Out of optional value for operatingState
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
