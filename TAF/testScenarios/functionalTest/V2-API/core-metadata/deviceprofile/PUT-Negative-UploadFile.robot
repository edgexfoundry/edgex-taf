*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile PUT Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-put-upload-negative.log
${api_version}    v2

*** Test Cases ***
ErrProfilePUTUpload001 - Update device profile by upload file and profile name is not existed
    When Upload File Test-Profile-1.yaml To Update Device Profile
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Run Keyword And Expect Error  "*not found"  Query device profile by name  Test-Profile-1

ErrProfilePUTUpload002 - Update device profile by upload file with profile name validation error
    # Empty profile name
    # Contains valid profile body
    Given Upload Device Profile Test-Profile-1.yaml
    And Generate New Test-Profile-1.yaml With "profile" Property "name" Value "${EMPTY}"
    When Upload File NEW-Test-Profile-1.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Profile By Name  Test-Profile-1
    ...                  AND  Delete Profile Files  NEW-Test-Profile-1.yaml

ErrProfilePUTUpload003 - Update device profile by upload file with deviceResources validation error
    # Empty deviceResources
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Generate New Test-Profile-1.yaml With "profile" Property "deviceResources" Value "@{EMPTY}"
    When Upload File NEW-Test-Profile-1.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-1.yaml

ErrProfilePUTUpload004 - Update device profile by upload file with PropertyValue validation error
    # deviceResources > PropertyValue without valueType
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Generate New Test-Profile-2.yaml With "deviceResources-properties" Property "valueType" Value "${EMPTY}"
    When Upload File NEW-Test-Profile-2.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-2.yaml

ErrProfilePUTUpload005 - Update device profile by upload file with ProfileResource validation error
    # deviceCommands > ProfileResource without name
    # Contains valid profile body
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Generate New Test-Profile-3.yaml With "deviceCommands" Property "name" Value "${EMPTY}"
    When Upload File NEW-Test-Profile-3.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-3.yaml

ErrProfilePUTUpload006 - Update device profile by upload file with coreCommands name validation error
    # Contains valid profile body
    # coreCommands without name
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Generate New Test-Profile-4.yaml With "coreCommands" Property "name" Value "${EMPTY}"
    When Upload File NEW-Test-Profile-4.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePUTUpload007 - Update device profile by upload file with coreCommands command validation error
    # Contains valid profile body
    # Duplicated device profile name
    # coreCommands get and set both are false
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Generate New Test-Profile-4.yaml With "coreCommands" Property "get" Value "${false}"
    When Upload File NEW-Test-Profile-4.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-4.yaml
