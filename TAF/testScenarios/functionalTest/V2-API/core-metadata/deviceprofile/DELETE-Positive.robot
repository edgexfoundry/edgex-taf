*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Profile DELETE Positive Test Cases

*** Test Cases ***
ProfileDELETE001 - Delete device profile by ID
    Given Create A Device Profile
    When Delete Device Profile By ID
    Then Should Return Status Code "200"
    And Device Profile Should Be Deleted
    And Response Time Should Be Less Than "1200"ms

ProfileDELETE002 - Delete device profile by name
    Given Create A Device Profile
    When Delete Device Profile By Name
    Then Should Return Status Code "200"
    And Device Should Be Deleted
    And Response Time Should Be Less Than "1200"ms
