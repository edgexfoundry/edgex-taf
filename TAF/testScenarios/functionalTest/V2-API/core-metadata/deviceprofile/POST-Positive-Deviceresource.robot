*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Resource Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-deviceresource-positive.log

*** Test Cases ***
ProfileResourcePOST001 - Add multiple Resources on device profile
    # multiple resources > one profile
    Given Generate a device profile and Add multiple Resources on device profile
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New Resource SwitchButton in Test-Profile-1 Should Be Added
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ProfileResourcePOST002 - Add multiple Resources on multiple device profiles
    # multiple resources > multiple profiles
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Add multiple Resources on multiple device profile
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New Resource SwitchButton in Test-Profile-1 Should Be Added
    And New Resource Temperature in Test-Profile-2 Should Be Added
    And New Resource BinaryInput1 in Test-Profile-3 Should Be Added
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

*** Keywords ***
New Resource ${resource_name} in ${profile_name} Should Be Added
    Query device profile by name  ${profile_name}
    ${resource_name_list}  Create List
    FOR  ${resource}  IN  @{content}[profile][deviceResources]
            Append To List  ${resource_name_list}  ${resource}[name]
    END
    List Should Contain Value  ${resource_name_list}  ${resource_name}
