*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core-Data Info GET Positive Testcases

*** Test Cases ***
InfoGET001 - Query ping
    When Query Ping
    Then Should Return Status Code "200" And Timestamp

InfoGET002 - Query version
    When Query Version
    Then Should Return Status Code "200" And Version

InfoGET003 - Query metrics
    When Query Metrics
    Then Should Return Status Code "200" And Metrics

InfoGET004 - Query config
    When Query Config
    Then Should Return Status Code "200" And Config
