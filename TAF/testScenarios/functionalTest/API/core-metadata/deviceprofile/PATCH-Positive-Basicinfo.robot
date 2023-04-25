*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Profile PATCH Basicinfo Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-basicinfo-positive.log

*** Test Cases ***
ProfileBasicInfoPATCH001 - Update one basicinfo of device profile
    # Update one basicinfo on one device profile
    Given Generate a basicinfo sample for updating
    When Update basicinfo ${basicinfoProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Profile Test-Profile-1 Basicinfo "description" Should Be Updated
    [Teardown]  Delete device profile by name  ${test_profile}

ProfileBasicInfoPATCH002 - Update multiple basicinfos of device profile
    # Update multiple basicinfo on one device profile
    Given Set Test Variable  ${test_profile}  Test-Profile-1
    And Generate A Device Profile Sample  ${test_profile}
    And Create Device Profile ${deviceProfile}
    And Generate multiple basicinfo sample for updating  ${test_profile}  ${test_profile}  ${test_profile}
    When Update basicinfo ${basicinfoProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Profile Test-Profile-1 Basicinfo "description" Should Be Updated
    And Profile Test-Profile-1 Basicinfo "manufacturer" Should Be Updated
    And Profile Test-Profile-1 Basicinfo "model" Should Be Updated
    And Profile Test-Profile-1 Basicinfo "labels" Should Be Updated
    [Teardown]  Delete device profile by name  ${test_profile}

ProfileBasicInfoPATCH003 - Update multiple basicinfos of multiple device profiles
    # Update multiple basicinfos on multiple device profiles
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Generate multiple basicinfo sample for updating  Test-Profile-1  Test-Profile-2  Test-Profile-3
    When Update basicinfo ${basicinfoProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Profile Test-Profile-1 Basicinfo "description" Should Be Updated
    And Profile Test-Profile-2 Basicinfo "manufacturer" Should Be Updated
    And Profile Test-Profile-3 Basicinfo "model" Should Be Updated
    And Profile Test-Profile-3 Basicinfo "labels" Should Be Updated
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

*** Keywords ***
Generate multiple basicinfo sample for updating
    [Arguments]  ${test_profile_1}  ${test_profile_2}  ${test_profile_3}
    ${labels}  Create List  Label_123  Label_456  Label_789
    ${basicinfo_1}=  Create Dictionary  name=${test_profile_1}  description=Dcp_ABC
    ${basicinfo_2}=  Create Dictionary  name=${test_profile_2}  manufacturer=Mfr_ABC
    ${basicinfo_3}=  Create Dictionary  name=${test_profile_3}  model=Model_ABC  labels=${labels}
    Generate basicinfo  ${basicinfo_1}  ${basicinfo_2}  ${basicinfo_3}

Profile ${test_profile} Basicinfo "${property}" Should Be Updated
    ${labels}  Create List  Label_123  Label_456  Label_789
    Query device profile by name  ${test_profile}
    Run Keyword IF  "${property}" == "description"  Should Be Equal  ${content}[profile][description]  Dcp_ABC
    ...    ELSE IF  "${property}" == "manufacturer"  Should Be Equal  ${content}[profile][manufacturer]  Mfr_ABC
    ...    ELSE IF  "${property}" == "model"  Should Be Equal  ${content}[profile][model]  Model_ABC
    ...    ELSE IF  "${property}" == "labels"  Should Be Equal  ${content}[profile][labels]  ${labels}
