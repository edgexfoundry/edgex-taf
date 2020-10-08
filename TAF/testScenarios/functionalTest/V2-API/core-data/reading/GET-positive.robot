*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Reading GET Postive Testcases

*** Test Cases ***
ReadingGET001 - Query all readings
    Given Create Multiple Events
    When Query All Readings
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Readings Should Be Matched
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

ReadingGET002 - Query reading by ID
    Given Create An Event
    When Query Reading By ID
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Readings Should Be Matched
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

ReadingGET003 - Query all readings with specified device by device id
    Given Create Multiple Events With Several Devices
    When Query All Readings With Specified Device
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Readings Should Be Linked To Specified Device
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

ReadingGET004 - Query readings by start/end time
    Given Create Multiple Events
    When Query Readings By Start/End Time
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Readings Should Be Created Within Given Time
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

ReadingGET005 - Query readings by valueType
    Given Create Multiple Events With Several ValueType
    When Query Readings By ValueType
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Readings Should Match ValueType
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

ReadingGET005 - Query a count of all of readings
    Given Create Multiple Events
    When Query All Readings Count
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Count Should Be Correct
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events

ReadingGET006 - Query a count of all of readings with specified device by device id
    Given Create Multiple Events With Several Devices
    When Query All Readings Count With Specified Device
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Count Should Be Correct
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Events
