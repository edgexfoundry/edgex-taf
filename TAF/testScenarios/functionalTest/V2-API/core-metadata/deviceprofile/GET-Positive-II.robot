*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Profile GET Positive Test Cases

*** Test Cases ***
ProfileGET009 - Query device profiles by manufacturer's model
    # Multiple device profile which part of same manufacturer and same model
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer And Model
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer And Model
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET010 - Query device profiles by manufacturer's model and offset
    # Multiple device profile which part of same manufacturer and same model
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer And Model
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer And Model
    And Validate Response Schema
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET011 - Query device profiles by manufacturer's model and limit
    # Multiple device profile which part of same manufacturer and same model
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer And Model
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Manufacturer And Model
    And Validate Response Schema
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET012 - Query device profiles by model
    # Multiple device profile with different manufacturer but same model
    Given Create Multiple Device Profiles
    When Query Device Profile By Model
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Model
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET013 - Query device profiles by model and offset
    # Multiple device profile with different manufacturer but same model
    Given Create Multiple Device Profiles
    When Query Device Profile By Model
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Model
    And Validate Response Schema
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET014 - Query device profiles by model and limit
    # Multiple device profile with different manufacturer but same model
    Given Create Multiple Device Profiles
    When Query Device Profile By Model
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Profile Should Be Linked To Specified Model
    And Validate Response Schema
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET015 - Query device profiles by empty manufacturer value
    # Multiple device profile which part of same manufacturer and same model
    Given Create Multiple Device Profiles
    When Query Device Profile By Manufacturer
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Response Body Should Be An Empty Array
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles

ProfileGET016 - Query device profiles by empty model value
    # Multiple device profile which part of same manufacturer and same model
    Given Create Multiple Device Profiles
    When Query Device Profile By Model
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Response Body Should Be An Empty Array
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Profiles
