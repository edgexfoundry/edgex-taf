*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Profile GET Positive Test Cases

*** Test Cases ***
ProfileGET001 - Query all device profiles
    Given Create Multiple Device Profiles
    When Query All Device Profiles
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET002 - Query all device profiles by offset
    Given Create Multiple Device Profiles
    When Query All Device Profiles
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET003 - Query all device profiles by limit
    Given Create Multiple Device Profiles
    When Query All Device Profiles
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET004 - Query all device profiles by labels
    Given Create Multiple Device Profiles
    When Query All Device Profiles
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Profiles Should Be Linked To Specified Label
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET005 - Query device profile by name
    Given Create A Device Profile
    When Query Device Profile By Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET006 - Query device profiles by manufacturer
    # Multiple device profile which part of same manufacturer
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET007 - Query device profiles by manufacturer and offset
    # Multiple device profile which part of same manufacturer
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer
    And Validate Response Schema
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET008 - Query device profiles by manufacturer and limit
    # Multiple device profile which part of same manufacturer
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer
    And Validate Response Schema
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles
