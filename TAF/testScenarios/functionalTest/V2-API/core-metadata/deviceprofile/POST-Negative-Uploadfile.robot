*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile POST For Upload File Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-upload-negative.log

*** Test Cases ***
ErrProfilePOSTUpload001 - Create device profile by upload file with duplicate profile name
    # Profile name is existed
    Given Upload Device Profile Test-Profile-4.yaml
    When Upload Device Profile Test-Profile-4.yaml
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  Test-Profile-4

ErrProfilePOSTUpload002 - Create device profile by upload file with profile name validation error
    # Empty profile name
    Given Generate New Test-Profile-4.yaml With "profile" Property "name" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload003 - Create device profile by upload file with ResourceProperties valueType validation error
    # deviceResources > ResourceProperties without valueType
    Given Generate New Test-Profile-4.yaml With "deviceResources-properties" Property "valueType" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload004 - Create device profile by upload file with ResourceProperties readWrite validation error
    # deviceResources > ResourceProperties without readWrite
    Given Generate New Test-Profile-4.yaml With "deviceResources-properties" Property "readWrite" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload005 - Create device profile by upload file with deviceCommand name validation error
    # deviceCommands > deviceCommand without name
    Given Generate New Test-Profile-4.yaml With "deviceCommands" Property "name" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload006 - Create device profile by upload file with deviceCommand readWrite validation error
    # deviceCommands > deviceCommand without name
    Given Generate New Test-Profile-4.yaml With "deviceCommands" Property "readWrite" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload007 - Create device profile by upload file with deviceCommand resourceOperations validation error
    # resourceOperations without deviceResource
    Given Generate New Test-Profile-4.yaml With "deviceCommands-resourceOperations" Property "deviceResource" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload008 - Create device profile by upload file with deviceCommands deviceResource validation error
    # deviceCommand contains deviceResource that only allows "read"
    Given Generate New Test-Profile-2.yaml With "deviceCommands" Property "readWrite" Value "W"
    When Upload Device Profile NEW-Test-Profile-2.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-2.yaml


