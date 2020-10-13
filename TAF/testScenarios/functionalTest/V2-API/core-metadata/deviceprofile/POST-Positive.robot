*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Profile POST Test Cases


*** Test Cases ***
ProfilePOST001 - Create device profile with json body
    When Create Multiple Device Profiles
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "1200"ms

ProfilePOST002 - Create device profile by upload file
    When Upload Device Profile
    Then Should Return Status Code "201"
    And Should Have Content-Type "application/json"
    And Should Contains UUID
    And Response Time Should Be Less Than "1200"ms
