*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device POST Test Cases


*** Test Cases ***
ErrDevicePOST001 - Create device with duplicate device name
    # 2 devices with same device name
    When Create multiple device
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "201" And id
    And Item Index 1 Should Contain Status Code "409"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePOST002 - Create device with device name validate error
    # Empty device name
    When Create multiple device
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePOST003 - Create device with adminState validate error
    # Empty adminState
    When Create multiple device
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePOST004 - Create device with operatingState validate error
    # Empty operatingState
    When Create multiple device
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePOST005 - Create device with serviceName validate error
    # Empty serviceName
    When Create multiple device
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePOST006 - Create device with profileName validate error
    # Empty profileName
    When Create multiple device
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePOST007 - Create device with protocols validate error
    # Empty protocols
    When Create multiple device
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePOST008 - Create device with adminState value validate error
    # Out of optional value for adminState
    When Create multiple device
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDevicePOST009 - Create device with operatingState value validate error
    # Out of optional value for operatingState
    When Create multiple device
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
