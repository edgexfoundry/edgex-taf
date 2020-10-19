*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Profile DELETE Negative Test Cases

*** Test Cases ***
ErrProfileDELETE001 - Delete device profile by invalid format ID
    # ID is existed, but format is invalid
    Given Create A Device Profile
    When Delete Device Profile By ID
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfileDELETE002 - Delete device profile by non-existent ID
    When Delete Device Profile By ID
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrProfileDELETE003 - Delete device profile by ID that used by device
    Given Create A Device Profile
    And Create A Device
    When Delete Device Profile By ID
    Then Should Return Status Code "423"
    And Response Time Should Be Less Than "1200"ms

ErrProfileDELETE004 - Delete device profile by empty name
    When Delete Device Profile By Name
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfileDELETE005 - Delete device profile by non-existent name
    When Delete Device Profile By Name
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrProfileDELETE006 - Delete device profile by name that used by device
    Given Create A Device Profile
    And Create A Device
    When Delete Device Profile By Name
    Then Should Return Status Code "423"
    And Response Time Should Be Less Than "1200"ms
