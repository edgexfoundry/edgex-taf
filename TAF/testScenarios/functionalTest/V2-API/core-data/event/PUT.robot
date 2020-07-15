*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Event PUT Testcases

*** Test Cases ***
EventPUT001 - Update event pushed time
    Given Create Multiple Events
    When Update Multiple Events
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Each Item Should Contain Status Code "200" and checksum
    And Each Item Pushed Time Should Be Updated
    [Teardown]  Delete Events

ErrEventPUT001 - Update event pushed time fails
    Given Create Multiple Events
    When Update Multiple Events With Invalid Checksum
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Each Item Should Contain Status Code "404" and no checksum
    [Teardown]  Delete Events

ErrEventPUT002 - Update event pushed time fails (Partial Failure)
    Given Create Multiple Events
    When Update Multiple Events With Valid Checksum And Invalid Checksum
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Should Contain Status Code "200" and checksum
    And Item Should Contain Status Code "404" and no checksum
    [Teardown]  Delete Events