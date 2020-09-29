*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Service GET Negative Test Cases

*** Test Cases ***
ErrServiceGET001 - Query device service by empty name
    When Query Device Service By Name
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrServiceGET002 - Query device service by non-existent name
    When Query Device Service By Name
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrServiceGET003 - Query all device service with non-int value on offset/limit
    Given Create Device Service
    When Query All Device Services
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
