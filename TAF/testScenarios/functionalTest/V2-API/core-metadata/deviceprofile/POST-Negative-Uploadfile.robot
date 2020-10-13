*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}         Core Metadata Device Profile POST For Upload File Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-upload-negative.log
${api_version}    v2

*** Test Cases ***
ErrProfilePOSTUpload001 - Create device profile by upload file with duplicate profile name
    # Profile name is existed
    [Tags]  Skipped
    Given Upload Device Profile Test-Profile-4.yaml
    When Upload Device Profile Test-Profile-4.yaml
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  Test-Profile-4

ErrProfilePOSTUpload002 - Create device profile by upload file with profile name validation error
    # Empty profile name
    Given Generate New Test-Profile-4.yaml With Bad "profile" Property "name" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload003 - Create device profile by upload file with deviceResources validation error
    # Empty deviceResources
    Given Generate New Test-Profile-4.yaml With Bad "profile" Property "deviceResources" Value "@{EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload004 - Create device profile by upload file with PropertyValue validation error
    # deviceResources > PropertyValue without type
    Given Generate New Test-Profile-4.yaml With Bad "deviceResources-properties" Property "type" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload005 - Create device profile by upload file with ProfileResource validation error
    # deviceCommands > ProfileResource without name
    Given Generate New Test-Profile-4.yaml With Bad "deviceCommands" Property "name" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload006 - Create device profile by upload file with coreCommands name validation error
    # coreCommands without name
    Given Generate New Test-Profile-4.yaml With Bad "coreCommands" Property "name" Value "${EMPTY}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

ErrProfilePOSTUpload007 - Create device profile by upload file with coreCommands command validation error
    # coreCommands get and put both are false
    Given Generate New Test-Profile-4.yaml With Bad "coreCommands" Property "get" Value "${false}"
    When Upload Device Profile NEW-Test-Profile-4.yaml
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Profile Files  NEW-Test-Profile-4.yaml

*** keywords ***
Generate New ${file} With Bad "${dict}" Property "${property}" Value "${value}"
    ${yaml_dict}=  Load yaml file "core-metadata/deviceprofile/${file}" and convert to dictionary
    Run Keyword IF  "${dict}" == "profile"  Set to Dictionary  ${yaml_dict}  ${property}=${value}
    ...    ELSE IF  "${dict}" == "deviceResources-properties"  Set to Dictionary  ${yaml_dict}[deviceResources][0][properties]  ${property}=${value}
    ...    ELSE IF  "${dict}" == "deviceCommands"  Set to Dictionary  ${yaml_dict}[deviceCommands][0]  ${property}=${value}
    ...    ELSE IF  "${dict}" == "coreCommands"  Set to Dictionary  ${yaml_dict}[coreCommands][1]  ${property}=${value}
    ${yaml}=  yaml.Safe Dump  ${yaml_dict}
    Create File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/NEW-${file}  ${yaml}

Delete Profile Files
    [Arguments]  ${file}
    Remove File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/${file}

