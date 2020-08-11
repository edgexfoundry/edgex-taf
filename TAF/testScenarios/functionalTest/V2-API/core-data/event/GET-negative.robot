*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Event GET Negative Testcases

*** Test Cases ***
ErrEventGET001 - Query event by ID fails
    When Query Event By invalid ID
    Then Should Return Status Code "404"

ErrEventGET002 - Query all events with specified device by device id fails
    When Query All Events with Specified Device By Invalid Device ID
    Then Should return Status Code "404"

ErrEventGET003 - Query events by start/end time fails (Invalid Start)
    When Query Events By Invalid Start Time
    Then Should Return Status Code "400"

ErrEventGET004 - Query events by start/end time fails (Invalid End)
    When Query Events By Invalid End Time
    Then Should Return Status Code "400"

ErrEventGET005 - Query events by start/end time fails (Start>End)
    When Query Events By Invalid Start/End Time
    Then Should Return Status Code "400"

ErrEventGET006 - Query a count of all of events with specified device by device id fails
    When Query All Events Count With Specified Device By Invalid Device ID
    Then Should Return Status Code "404"
