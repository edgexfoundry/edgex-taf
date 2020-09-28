*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device Profile POST Negative Test Cases


*** Test Cases ***
ErrProfilePOST001 - Create device profile with duplicate profile name
    # 2 device profiles with same profile name
    When Create Multiple Device Profiles
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "201" And id
    And Item Index 1 Should Contain Status Code "409"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOST002 - Create device profile with profile name validation error
    # Empty profile name
    # Contains valid profile body
    When Create Multiple Device Profiles
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOST003 - Create device profile with deviceResources validation error
    # Empty deviceResources
    # Contains valid profile body
    When Create Multiple Device Profiles
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOST004 - Create device profile with PropertyValue validation error
    # deviceResources > PropertyValue without type
    # Contains valid profile body
    When Create Multiple Device Profiles
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOST005 - Create device profile with ProfileResource validation error
    # deviceCommands > ProfileResource without name
    # Contains valid profile body
    When Create Multiple Device Profiles
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOST006 - Create device profile with coreCommands name validation error
    # Contains valid profile body
    # coreCommands without name
    When Create Multiple Device Profiles
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePOST007 - Create device profile with coreCommands command validation error
    # Contains valid profile body
    # Duplicated device profile name
    # coreCommands get and put both are false
    When Create Multiple Device Profiles
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
