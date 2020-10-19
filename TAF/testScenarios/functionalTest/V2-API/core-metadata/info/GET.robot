*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Info GET Test Cases

*** Test Cases ***
InfoGET001 - Query ping
    When Query Ping
    Then Should Return Status Code "200" And Timestamp
    And Response Time Should Be Less Than "1200"ms

InfoGET002 - Query version
    When Query Version
    Then Should Return Status Code "200" And Version
    And Response Time Should Be Less Than "1200"ms

InfoGET003 - Query metrics
    When Query Metrics
    Then Should Return Status Code "200" And Metrics
    And Response Time Should Be Less Than "1200"ms

InfoGET004 - Query config
    When Query Config
    Then Should Return Status Code "200" And Config
    And Response Time Should Be Less Than "1200"ms
