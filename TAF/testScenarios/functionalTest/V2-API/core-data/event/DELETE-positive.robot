*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Event DELETE Positive Testcases

*** Test Cases ***
EventDELETE001 - Delete event by ID
    Given Create An Event
    When Delete Event By ID
    Then Should Return Status Code "204"
    And Event Should Be Deleted
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

EventDELETE002 - Delete events with specified device by device id
    Given Create Multiple Events
    When Delete Events With Specified Device
    Then Should Return Status Code "204"
    And Events With Specified Device Should Be Deleted
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

EventDELETE003 - Delete all old events (and associated readings) based on delimiting age
    Given Create Multiple Events
    When Delete Events By Age
    Then Should Return Status Code "204"
    And Old Events Should Be Deleted
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

