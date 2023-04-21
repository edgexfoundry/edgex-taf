*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Profile DELETE Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-delete-negative.log

*** Test Cases ***
ErrProfileDELETE001 - Delete device profile by non-existent name
    When Delete Device Profile By Name  Invalid_Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileDELETE002 - Delete device profile by name that used by device
    Given Create A Device Sample With Associated device-virtual And Test-Profile-2
    When Delete Device Profile By Name  Test-Profile-2
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

ErrProfileDELETE003 - Delete device profile by name that used by rovisionwatcher
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Create Provision Watcher ${provisionwatcher}
    When Delete Device Profile By Name  Test-Profile-1
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProfileDELETE004 - Delete device profile by name when StrictDeviceProfileDeletes is true
    Given Set ProfileChange.StrictDeviceProfileDeletes=true For Core-Metadata On Consul
    And Generate A Device Profile Sample  Test-Profile-2
    And Create device profile ${deviceProfile}
    When Delete Device Profile By Name  Test-Profile-2
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set ProfileChange.StrictDeviceProfileDeletes=false For Core-Metadata On Consul
    ...                  AND  Delete Device Profile By Name  Test-Profile-2
