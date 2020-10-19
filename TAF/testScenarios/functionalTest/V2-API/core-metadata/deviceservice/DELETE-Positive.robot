*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Service DELETE Positive Test Cases

*** Test Cases ***
ServiceDELETE001 - Delete device service by ID
    Given Create A Device Service
    When Delete Device Service By ID
    Then Should Return Status Code "200"
    And Device Service Should Be Deleted
    And Response Time Should Be Less Than "1200"ms

ServiceDELETE002 - Delete device service by name
    Given Create A Device Service
    When Delete Device Service By Name
    Then Should Return Status Code "200"
    And Device Should Be Deleted
    And Response Time Should Be Less Than "1200"ms
