*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Profile GET Negative Test Cases

*** Test Cases ***
ErrProfileGET001 - Query device profile by empty name
    When Query Device Profile By Name
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfileGET002 - Query device profile by non-existent name
    When Query Device Profile By Name
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrProfileGET003 - Query device profiles by empty manufacturer value
    When Query Device Profile By Manufacturer
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfileGET004 - Query device profiles by existed manufacturer and empty model value
    When Query Device Profile By Manufacturer And Model
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfileGET005 - Query device profiles by empty model value
    When Query Device Profile By Model
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfileGET006 - Query all device profile with non-int value on offset/limit
    When Query All Device Profiles
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
