*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile PUT Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-put-positive.log
${api_version}    v2

*** Test Cases ***
ProfilePUT001 - Update a device profile
    Given Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[0][profile]  manufacturer=Mfr_ABC
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Profile Test-Profile-1 Data "manufacturer" Should Be Updated
    [Teardown]  Delete Device Profile By Name  Test-Profile-1

ProfilePUT002 - Update multiple device profiles
    # Update different field for different profile
    [Tags]  SmokeTest
    Given Generate Multiple Device Profiles Sample
    And Create device profile ${deviceProfile}
    And Set To Dictionary  ${deviceProfile}[0][profile]   model=Model_ABC
    And Set To Dictionary  ${deviceProfile}[1][profile][deviceResources][1][properties]  valueType=Float64
    And Set To Dictionary  ${deviceProfile}[2][profile][coreCommands][0]  set=${true}
    When Update Device Profile ${deviceProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Profile Test-Profile-1 Data "model" Should Be Updated
    And Profile Test-Profile-2 Data "deviceResources-properties" Should Be Updated
    And Profile Test-Profile-3 Data "coreCommands" Should Be Updated
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfilePUT003 - Update device profiles by upload file
    Given Upload Device Profile Test-Profile-2.yaml
    And Generate New Test-Profile-2.yaml With "profile" Property "manufacturer" Value "Mfr_ABC"
    When Upload File NEW-Test-Profile-2.yaml To Update Device Profile
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Profile Test-Profile-2 Data "manufacturer" Should Be Updated
    [Teardown]  Run Keywords  Delete Device Profile By Name  Test-Profile-2
    ...                  AND  Delete Profile Files  NEW-Test-Profile-2.yaml

*** Keywords ***
Profile ${device_profile_name} Data "${property}" Should Be Updated
    Query device profile by name  ${device_profile_name}
    Run Keyword IF  "${property}" == "manufacturer"  Should Be Equal  ${content}[profile][manufacturer]  Mfr_ABC
    ...    ELSE IF  "${property}" == "model"  Should Be Equal  ${content}[profile][model]  Model_ABC
    ...    ELSE IF  "${property}" == "deviceResources-properties"
    ...             Should Be Equal  ${content}[profile][deviceResources][1][properties][valueType]  Float64
    ...    ELSE IF  "${property}" == "coreCommands"  Should Be Equal  ${content}[profile][coreCommands][0][set]  ${true}

