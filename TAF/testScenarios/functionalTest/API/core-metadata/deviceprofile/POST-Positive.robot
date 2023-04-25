*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-positive.log

*** Test Cases ***
ProfilePOST001 - Create device profile with json body
    [Tags]  SmokeTest
    Given Generate Multiple Device Profiles Sample
    When Create Device Profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[1][profile]  deviceResources=@{EMPTY}
    And Set To Dictionary  ${deviceProfile}[1][profile]  deviceCommands=@{EMPTY}
    And Remove From Dictionary  ${deviceProfile}[2][profile]  deviceResources
    And Remove From Dictionary  ${deviceProfile}[2][profile]  deviceCommands
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfilePOST002 - Create device profile by upload file
    When Upload Device Profile Test-Profile-4.yaml
    Then Should Return Status Code "201"
    And Should Return Content-Type "application/json"
    And Should Contain "id"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  Test-Profile-4

ProfilePOST003 - Create device profile by upload file with empty deviceResources and deviceCommands
    When Upload Device Profile With Empty DeviceResources And DeviceCommands
    log to console  ${content}
    Then Should Return Status Code "201"
    And Should Return Content-Type "application/json"
    And Should Contain "id"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Profile By Name  ${profile_name}
    ...                  AND  Delete Profile Files  ${upload_profile}

ProfilePOST004 - Create device profile by upload file without deviceResources and deviceCommands
    When Upload Device Profile Without DeviceResources And DeviceCommands
    Then Should Return Status Code "201"
    And Should Return Content-Type "application/json"
    And Should Contain "id"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Profile By Name  ${profile_name}
    ...                  AND  Delete Profile Files  ${upload_profile}

ProfilePOST005 - Create device profile with json body and contains valid unit value
    Given Update Service Configuration On Consul  ${uomValidationPath}  true
    When Create A Profile Test-Profile-1 With valid Units Value
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Update Service Configuration On Consul  ${uomValidationPath}  false
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

ProfilePOST006 - Create device profile by upload file and the update file contains valid unit value
    Given Update Service Configuration On Consul  ${uomValidationPath}  true
    When Modify Device Profile Test-Profile-1 With valid Units Value
    Then Should Return Status Code "201"
    And Should Return Content-Type "application/json"
    And Should Contain "id"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Update Service Configuration On Consul  ${uomValidationPath}  false
    ...                  AND  Delete Device Profile By Name  Test-Profile-1
    ...                  AND  Delete Profile Files  NEW-Test-Profile-1.yaml

*** Keywords ***
Upload Device Profile With Empty DeviceResources And DeviceCommands
    Set Test Variable  ${profile_name}  Test-Profile-4
    Set Test Variable  ${upload_profile}  Profile-Empty-DeviceResource-DeviceCommand.yaml
    ${yaml_dict}=  Load yaml file "core-metadata/deviceprofile/${profile_name}.yaml" and convert to dictionary
    Set to Dictionary  ${yaml_dict}  deviceResources=@{EMPTY}
    Set to Dictionary  ${yaml_dict}  deviceCommands=@{EMPTY}
    ${yaml}=  yaml.Safe Dump  ${yaml_dict}
    Create File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/${upload_profile}  ${yaml}
    Upload Device Profile ${upload_profile}

Upload Device Profile Without DeviceResources And DeviceCommands
    Set Test Variable  ${profile_name}  Test-Profile-4
    Set Test Variable  ${upload_profile}  Profile-Without-DeviceResource-DeviceCommand.yaml
    ${yaml_dict}=  Load yaml file "core-metadata/deviceprofile/${profile_name}.yaml" and convert to dictionary
    Remove From Dictionary  ${yaml_dict}  deviceResources
    Remove From Dictionary  ${yaml_dict}  deviceCommands
    ${yaml}=  yaml.Safe Dump  ${yaml_dict}
    Create File  ${WORK_DIR}/TAF/testData/core-metadata/deviceprofile/${upload_profile}  ${yaml}
    Upload Device Profile ${upload_profile}
