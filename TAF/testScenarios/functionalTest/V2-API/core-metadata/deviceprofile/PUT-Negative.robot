*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile PUT Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-put-negative.log

*** Test Cases ***
ErrProfilePUT001 - Update device profile with invalid profile name
    # Non-existent profile name
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[2][profile]  name=Non-existent
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "207"
    And Item Index 2 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Run Keyword And Expect Error  "*not found"  Query device profile by name  Non-existent
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProfilePUT002 - Update device profile with profile name validation error
    # Empty profile name
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[1][profile]  name=${EMPTY}
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProfilePUT003 - Update device profile with deviceResources validation error
    # Empty deviceResources
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[1][profile]  deviceResources=@{EMPTY}
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProfilePUT004 - Update device profile with ResourceProperties validation error
    # deviceResources > ResourceProperties without valueType
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceResources][0][properties]  valueType=${EMPTY}
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProfilePUT005 - Update device profile with deviceCommands name validation error
    # deviceCommands > deviceCommand without name
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceCommands][0]  name=${EMPTY}
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProfilePUT006 - Update device profile with deviceCommands resourceOperations validation error
    # Contains valid profile body
    # deviceCommands > resourceOperations without deviceResource
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceCommands][0][resourceOperations][0]  deviceResource=${EMPTY}
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProfilePUT007 - Update device profile with deivceCommands deviceResource validation error
    # Contains valid profile body
    # Duplicated device profile name
    # deviceCommand contains part of deviceResources that only allow "read"
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[1][profile]  name=Test-Profile-1
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceCommands][0]  readWrite=W
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
