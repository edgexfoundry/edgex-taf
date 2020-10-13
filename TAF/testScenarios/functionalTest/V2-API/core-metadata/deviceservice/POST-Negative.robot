*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Service POST Negative Test Cases


*** Test Cases ***
ErrServicePOST001 - Create device service with duplicate service name
    # 2 device services with same service name
    When Create multiple device service
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "201" And id
    And Item Index 1 Should Contain Status Code "409"
    And Response Time Should Be Less Than "1200"ms

ErrServicePOSTValidate001 - Create device service with adminState validate error
    # Empty adminState
    When Create multiple device service
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrServicePOSTValidate002 - Create device service with operatingState validate error
    # Empty operatingState
    When Create multiple device service
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrServicePOSTValidate003 - Create device service with adminState value validate error
    # Out of optional value for adminState
    # Contains valid service body
    When Create multiple device service
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrServicePOSTValidate004 - Create device service with operatingState value validate error
    # Out of optional value for operatingState
    When Create multiple device service
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrServicePOSTValidate005 - Create device service with service name validate error
    # Empty service name
    When Create multiple device service
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrServicePOSTValidate006 - Create device service with baseAddress validate error
    # Empty baseAddress
    # Contains valid service body
    When Create multiple device service
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
