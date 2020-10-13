*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Profile POST For Upload File Negative Test Cases


*** Test Cases ***
ErrProfilePOSTUpload001 - Create device profile by upload file with duplicate profile name
    # Profile name is existed
    When Upload device profile
    Then Should Return Status Code "409"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOSTUpload002 - Create device profile by upload file with profile name validation error
    # Empty profile name
    When Upload device profile
    Then Should Return Status Code "400"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOSTUpload003 - Create device profile by upload file with deviceResources validation error
    # Empty deviceResources
    When Upload device profile
    Then Should Return Status Code "400"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOSTUpload004 - Create device profile by upload file with PropertyValue validation error
    # deviceResources > PropertyValue without type
    When Upload device profile
    Then Should Return Status Code "400"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOSTUpload005 - Create device profile by upload file with ProfileResource validation error
    # deviceCommands > ProfileResource without name
    When Upload device profile
    Then Should Return Status Code "400"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOSTUpload006 - Create device profile by upload file with coreCommands name validation error
    # coreCommands without name
    When Upload device profile
    Then Should Return Status Code "400"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOSTUpload007 - Create device profile by upload file with coreCommands command validation error
    # coreCommands get and put both are false
    When Upload device profile
    Then Should Return Status Code "400"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "1200"ms
