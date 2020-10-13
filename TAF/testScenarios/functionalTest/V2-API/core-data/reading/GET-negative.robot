*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Reading GET Negative Testcases

*** Test Cases ***
ErrReadingGET001 - Query reading by ID fails
    When Query Reading By Invalid ID
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET002 - Query all readings with specified device by device id fails
    When Query All Readings With Specified Device By Invalid Device ID
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET003 - Query readings by start/end time fails (Invalid Start)
    When Query Readings By Invalid Start Time
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET004 - Query readings by start/end time fails (Invalid End)
    When Query Readings By Invalid End Time
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET005 - Query readings by start/end time fails (Start>End)
    When Query Readings By Invalid Start/End Time
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET006 - Query readings by valueType fails
    When Query Readings By Invalid valueType
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrReadingGET007 - Query a count of all of readings with specified device by device id fails
    When Query All Readings Count With Specified Device By Invalid Device ID
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

