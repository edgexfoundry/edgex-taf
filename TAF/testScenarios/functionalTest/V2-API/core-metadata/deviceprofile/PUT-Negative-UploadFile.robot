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

ErrProfilePUTUpload004 - Update device profile by upload file with ResourceProperties validation error
    # deviceResources > ResourceProperties without valueType
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

ErrProfilePUTUpload005 - Update device profile by upload file with deviceCommand name validation error
    # deviceCommands > deviceCommand without name
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

ErrProfilePUTUpload006 - Update device profile by upload file with deviceCommands resourceOperations validation error
    # Contains valid profile body
    # deviceCommands > resourceOperations without deviceResource
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Generate New Test-Profile-4.yaml With "deviceCommands-resourceOperations" Property "deviceResource" Value "${EMPTY}"
    When Upload File NEW-Test-Profile-4.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePUTUpload007 - Update device profile by upload file with deivceCommands deviceResource validation error
    # Contains valid profile body
    # Duplicated device profile name
    # deviceCommand contains deviceResource that only allows "read"
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Generate New Test-Profile-2.yaml With "deviceCommands" Property "readWrite" Value "RW"
    When Upload File NEW-Test-Profile-2.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-2.yaml

ErrProfilePUTUpload008 - Update device profile by upload file when StrictDeviceProfileChanges is true
    Given Set ProfileChange.StrictDeviceProfileChanges=true For Core-Metadata On Consul
    And Upload Device Profile Test-Profile-3.yaml
    And Generate New Test-Profile-3.yaml With "profile" Property "manufacturer" Value "Mfr_ABC"
    When Upload File NEW-Test-Profile-3.yaml To Update Device Profile
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set ProfileChange.StrictDeviceProfileChanges=false For Core-Metadata On Consul
    ...                  AND  Delete Device Profile By Name  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-3.yaml

ErrProfilePUTUpload009 - Update device profile by upload file and the update file contains invalid unit value
    Given Upload Device Profile Test-Profile-3.yaml
    And Update Service Configuration On Consul  ${uomValidationPath}  true
    And Update Units Value In Profile Test-Profile-3 To invalid
    When Upload File NEW-Test-Profile-3.yaml To Update Device Profile
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Resource Units Should Not Be Updated in Test-Profile-3
    [Teardown]  Run Keywords  Update Service Configuration On Consul  ${uomValidationPath}  false
    ...                  AND  Delete Device Profile By Name  Test-Profile-3
    ...                  AND  Delete Profile Files  NEW-Test-Profile-3.yaml

*** Keywords ***
Resource Units Should Not Be Updated in ${profile_name}
    Retrieve Valid Units Value
    Query device profile by name  ${profile_name}
    # Validate
    FOR  ${INDEX}  IN RANGE  len(${content}[profile][deviceResources])
        ${properties}=  Get From Dictionary  ${content}[profile][deviceResources][${INDEX}]  properties
        IF  "units" in ${properties}
           List Should Not Contain Value  ${uom_units}  ${properties}[units]
        END
    END
