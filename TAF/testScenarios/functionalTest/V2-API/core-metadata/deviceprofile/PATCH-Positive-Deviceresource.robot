*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile PATCH Deviceresource Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-deviceresource-positive.log

*** Test Cases ***
ProfileResourcePATCH001 - Update one resource on one device profile
    # one resource > one profile
    Given Generate a profile and a resource sample for updating
    When Update resource ${resourceUpdate}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Resource DeviceValue_Boolean_RW in Profile Test-Profile-1 Should Be Updated
    [Teardown]  Delete Device Profile By Name  Test-Profile-1

ProfileResourcePATCH002 - Update multiple resources on multiple device profiles
    # multiple resources > multiple profiles
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Generate multiple resource sample for updating
    When Update resource ${resourceUpdate}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Resource DeviceValue_Boolean_RW in Profile Test-Profile-1 Should Be Updated
    And Resource DeviceValue_String_R in Profile Test-Profile-2 Should Be Updated
    And Resource DeviceValue_FLOAT32_R in Profile Test-Profile-3 Should Be Updated
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

*** Keywords ***
Generate multiple resource sample for updating
    ${resource_1}=  Create Dictionary  name=DeviceValue_Boolean_RW  description=Dcp_ABC  isHidden=${false}
    ${resource_2}=  Create Dictionary  name=DeviceValue_String_R  description=Dcp_ABC
    ${resource_3}=  Create Dictionary  name=DeviceValue_FLOAT32_R   isHidden=${false}
    Generate updating resource  ${resource_1}  ${resource_2}  ${resource_3}
    Set To Dictionary  ${resourceUpdate}[0]  profileName=Test-Profile-1
    Set To Dictionary  ${resourceUpdate}[1]  profileName=Test-Profile-2
    Set To Dictionary  ${resourceUpdate}[2]  profileName=Test-Profile-3

Resource ${resource_name} in Profile ${profile_name} Should Be Updated
    Query device resource by resourceName and profileName  ${resource_name}  ${profile_name}
    Run Keyword If  "${profile_name}" == "Test-Profile-1"
    ...             Run Keywords  Should Be Equal  ${content}[resource][description]   Dcp_ABC
    ...                      AND  Should Be Equal  ${content}[resource][isHidden]   ${false}
    ...    ELSE IF  "${profile_name}" == "Test-Profile-2"  Should Be Equal  ${content}[resource][description]   Dcp_ABC
    ...    ELSE IF  "${profile_name}" == "Test-Profile-3"  Should Be Equal  ${content}[resource][isHidden]   ${false}

