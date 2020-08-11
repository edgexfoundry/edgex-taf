*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Event DELETE Negative Testcases

*** Test Cases ***
ErrEventDELETE001 - Delete event by ID fails
    When Delete Event By Invalid ID
    Then Should Return Status Code "404"

ErrEventDELETE002 - Delete events with specified device by device id fails
    When Delete Events With Specified Device By Invalid Device ID
    Then Should Return Status Code "404"
