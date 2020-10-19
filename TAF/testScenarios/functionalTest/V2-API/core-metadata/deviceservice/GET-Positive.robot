*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Service GET Positive Test Cases

*** Test Cases ***
ServiceGET001 - Query all device services
    Given Create Multiple Device Services
    When Query All Device Services
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Services

ServiceGET001 - Query all device services by offset
    Given Create Multiple Device Services
    When Query All Device Services
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Skipped Records Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Services

ServiceGET001 - Query all device services by limit
    Given Create Multiple Device Services
    When Query All Device Services
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Services

ServiceGET001 - Query all device services by labels
    Given Create Multiple Device Services
    When Query All Device Services
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Device Services Should Be Linked To Specified Label
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Services

ServiceGET002 - Query device service by name
    Given Create A Device Service
    When Query Device Service By Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Device Services
