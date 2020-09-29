*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device PATCH Testcases


*** Test Cases ***
ErrDevicePATCH001 - Update device with use duplicate device name
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "409"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCH002 - Update device with device name validate error
    # Empty device name
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCH003 - Update device with adminState validate error
    # Empty adminState
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCH004 - Update device with operatingState validate error
    # Empty operatingState
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCH005 - Update device with serviceName validate error
    # Empty serviceName
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCH006 - Update device with profileName validate error
    # Empty profileName
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCH007 - Update device with protocols validate error
    # Empty protocols
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCH008 - Update device with adminState value validate error
    # Out of optional value for adminState
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePATCH009 - Update device with operatingState value validate error
    # Out of optional value for operatingState
    Given Create Multiple Devices
    When Update Multiple Devices
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
