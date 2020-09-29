*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}          Core Metadata Device Profile PUT Negative Test Cases

*** Test Cases ***
ErrProfilePUTUpload001 - Update device profile by upload file and profile name is not existed
    When Update Device Profile By Upload File
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUTUpload002 - Update device profile by upload file with profile name validation error
    # Empty profile name
    # Contains valid profile body
    Given Create Multiple Device Profiles
    When Update Device Profile By Upload File
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUTUpload003 - Update device profile by upload file with deviceResources validation error
    # Empty deviceResources
    # Contains valid profile body
    Given Create Multiple Device Profiles
    When Update Device Profile By Upload File
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUTUpload004 - Update device profile by upload file with PropertyValue validation error
    # deviceResources > PropertyValue without type
    # Contains valid profile body
    Given Create Multiple Device Profiles
    When Update Device Profile By Upload File
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUTUpload005 - Update device profile by upload file with ProfileResource validation error
    # deviceCommands > ProfileResource without name
    # Contains valid profile body
    Given Create Multiple Device Profiles
    When Update Device Profile By Upload File
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUTUpload006 - Update device profile by upload file with coreCommands name validation error
    # Contains valid profile body
    # coreCommands without name
    Given Create Multiple Device Profiles
    When Update Device Profile By Upload File
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrProfilePUTUpload007 - Update device profile by upload file with coreCommands command validation error
    # Contains valid profile body
    # Duplicated device profile name
    # coreCommands get and put both are false
    Given Create Multiple Device Profiles
    When Update Device Profile By Upload File
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms
