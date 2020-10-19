*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}          Core Metadata Device Profile PUT Positive Test Cases

*** Test Cases ***
ProfilePUT001 - Update a device profile
    # Update profile name
    Given Create A Device Profile
    When Update Device Profile
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Profile Data Should Be Updated
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Profiles

ProfilePUT002 - Update multiple device profiles
    # Update different field for different profile
    Given Create Multiple Device Profiles
    When Update Multiple Device Profile
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Profile Data Should Be Updated
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Profiles

ProfilePUT003 - Update device profiles by upload file
    Given Create Device Profiles
    When Update Device Profile
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Data Should Be Updated
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Profiles
