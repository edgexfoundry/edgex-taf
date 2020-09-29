*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}          Core Metadata Device Profile PUT Positive Test Cases

*** Test Cases ***
ErrProfilePUT001 - Update device profile with invalid profile name
    # Duplicate profile name
    # Non-existent profile name
    Given Create Multiple Device Profile
    When Update Device Profile
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "409"
    And Item Index 1 Should Contain Status Code "404"
    And Profile Data Should Not Be Updated
    And Response Time Should Be Less Than "1200"ms
    [Teardown]  Delete Profiles

ErrProfilePUT002 - Update device profile with profile name validation error
    # Empty profile name
    # Contains valid profile body
    Given Create Multiple Device Profiles
    When Update Device Profile
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUT003 - Update device profile with deviceResources validation error
    # Empty deviceResources
    # Contains valid profile body
    Given Create Multiple Device Profiles
    When Update Device Profile
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUT004 - Update device profile with PropertyValue validation error
    # deviceResources > PropertyValue without type
    # Contains valid profile body
    Given Create Multiple Device Profiles
    When Update Device Profile
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUT005 - Update device profile with ProfileResource validation error
    # deviceCommands > ProfileResource without name
    # Contains valid profile body
    Given Create Multiple Device Profiles
    When Update Device Profile
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUT006 - Update device profile with coreCommands name validation error
    # Contains valid profile body
    # coreCommands without name
    Given Create Multiple Device Profiles
    When Update Device Profile
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUT007 - Update device profile with coreCommands command validation error
    # Contains valid profile body
    # Duplicated device profile name
    # coreCommands get and put both are false
    Given Create Multiple Device Profiles
    When Update Device Profile
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
