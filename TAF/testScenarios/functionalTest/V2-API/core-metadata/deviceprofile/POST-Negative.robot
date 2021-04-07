*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-negative.log

*** Test Cases ***
ErrProfilePOST001 - Create device profile with duplicate profile name
    # 2 device profiles with same profile name
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile]  name=Test-Profile-1
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0,2 Should Contain Status Code "201" And id
    And Item Index 1 Should Contain Status Code "409" And no id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-3

ErrProfilePOST002 - Create device profile with profile name validation error
    # Empty profile name
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile]  name=${EMPTY}
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfilePOST003 - Create device profile with deviceResources validation error
    # Empty deviceResources
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile]  deviceResources=@{EMPTY}
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfilePOST004 - Create device profile with ResourceProperties valueType validation error
    # deviceResources > ResourceProperties without valueType
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceResources][0][properties]  valueType=${EMPTY}
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfilePOST005 - Create device profile with ResourceProperties readWrite validation error
    # deviceResources > ResourceProperties without readWrite
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceResources][0][properties]  readWrite=${EMPTY}
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfilePOST006 - Create device profile with deviceCommand name validation error
    # deviceCommands > deviceCommand without name
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceCommands][0]  name=${EMPTY}
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfilePOST007 - Create device profile with deviceCommand readWrite validation error
    # deviceCommands > deviceCommand without readWrite
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceCommands][0]  readWrite=${EMPTY}
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfilePOST008 - Create device profile with deviceCommand resourceOperations validation error
    # deviceCommands > resourceOperations without deviceResource
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceCommands][0][resourceOperations][0]  deviceResource=${EMPTY}
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfilePOST009 - Create device profile with deviceCommands deviceResources validation error
    # Contains valid profile body
    # Duplicated device profile name
    # deviceCommand contains part of deviceResources that only allow "read"
    Given Generate Multiple Device Profiles Sample
    And Set To Dictionary  ${deviceProfile}[1][profile]  name=Test-Profile-1
    And Set To Dictionary  ${deviceProfile}[0][profile][deviceCommands][2]  readWrite=RW
    When Create Device Profile ${deviceProfile}
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms


