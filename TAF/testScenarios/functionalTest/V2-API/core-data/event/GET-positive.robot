*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Event GET Postive Testcases

*** Test Cases ***
EventGET001 - Query all events
    Given Create Multiple Events
    When Query All Events
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    [Teardown]  Delete Events

EventGET002 - Query event by ID
    Given Create An Event
    When Query Event By ID
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Validate Response Schema
    [Teardown]  Delete Events

EventGET003 - Query all events with specified device by device id
    Given Create Multiple Events With Several Devices
    When Query All Events With Specified Device
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Events Should Be Linked To Specified Device
    [Teardown]  Delete Events

EventGET004 - Query events by start/end time
    Given Create Multiple Events
    When Query Events By Start/End Time
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Events Should Be Created Within Given Time
    [Teardown]  Delete Events

EventGET005 - Query a count of all of events
    Given Create Multiple Events
    When Query All Events Count
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Count Should Be Correct
    [Teardown]  Delete Events

EventGET006 - Query a count of all of events with specified device by device id
    Given Create Multiple Events with Several Devices
    When Query All Events Count With Specified Device
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Count Should Be Correct
    [Teardown]  Delete Events

