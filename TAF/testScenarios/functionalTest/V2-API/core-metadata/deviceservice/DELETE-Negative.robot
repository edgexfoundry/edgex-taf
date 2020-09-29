*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Service DELETE Negative Test Cases

*** Test Cases ***
ErrServiceDELETE001 - Delete device service by ID with invalid id format
    # use non uuid format, like d138fccc-f39a4fd0-bd32
    Given Create A Device Service
    When Delete Device Service By ID
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrServiceDELETE002 - Delete device service by ID that used by device
    Given Create A Device Service
    And Create A Device
    When Delete Device Service By ID
    Then Should Return Status Code "423"
    And Response Time Should Be Less Than "1200"ms

ErrServiceDELETE003 - Delete device service by ID with non-existent id
    When Delete Device Service By ID
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrServiceDELETE004 - Delete device service by name with empty name
    When Delete Device Service By Name
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrServiceDELETE005 - Delete device service by name that used by device
    Given Create A Device Service
    And Create A Device
    When Delete Device Service By Name
    Then Should Return Status Code "423"
    And Response Time Should Be Less Than "1200"ms

ErrServiceDELETE006 - Delete device service by name with non-existent service name
    When Delete Device Service By Name
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms
