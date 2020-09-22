*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Event POST Testcases

*** Test Cases ***
EventPOST001 - Create event with device name
    When Create Multiple Events
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Each Item Should Contain Status Code "201" and UUID
    [Teardown]  Delete Events

EventPOST002 - Create event with binary data
    When Create Multiple Events
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Each Item Should Contain Status Code "201" and UUID
    [Teardown]  Delete Events

ErrEventPOST001 - Create event with device name fails (Bad Readings)
    # contains "no reading", "no reading name", "no reading device name", "no reading origin",
    # "no reading value type", "no reading value"
    When Create Multiple Events With Invalid Reading
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Each Item Should Contain Status Code "400" and no UUID

ErrEventPOST002 - Create event with device name fails (Partial Failure)
    # contains "no reading float encoding", "no binary value", "no media type"
    When Create Multiple Events With Valid Reading And Invalid Reading
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Should Contain Status Code "201" and UUID
    And Item Should Contain Status Code "400" and no UUID
    [Teardown]  Delete Events

ErrEventPOST003 - Create event with device name fails (Bad Events)
    # contains "no event", "no event id", "bad event id", "no event device name" and "no event origin"
    When Create Multiple Events With Invalid Event
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Should Contain Status Code "400" and no UUID
    [Teardown]  Delete Events
