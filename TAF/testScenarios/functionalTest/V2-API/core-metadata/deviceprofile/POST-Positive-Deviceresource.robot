*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Resource Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-deviceresource-positive.log

*** Test Cases ***
ProfileResourcePOST001 - Add deviceResource on one device profile with deviceResource
    # one resource > one profile
    Given Create A Device Profile with deviceResource
    When Add A New resource on device profile
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New resources Should Be Added
    [Teardown]  Delete Device Profile By Name

ProfileResourcePOST002 - Add multiple deviceResources on one device profile basicinfo only
    # multiple resources > one basicinfo profile
    Given Create A Device Profile Basicinfo Only
    When Add multiple New resources on Device Profile Basicinfo Only
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New resources Should Be Added
    [Teardown]  Delete Device Profile By Name

ProfileResourcePOST003 - Add multiple deviceResources on multiple device profiles
    # multiple resources on profile basicinfo > multiple basicinfo profiles & profiles sample
    Given Create multiple Device Profiles Basicinfo Only
    And Create Multiple Device Profiles Sample
    When Add multiple New resources on Device Profiles Basicinfo Only
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And New resources Should Be Added
    [Teardown]  Delete Multiple Device Profiles By Names

