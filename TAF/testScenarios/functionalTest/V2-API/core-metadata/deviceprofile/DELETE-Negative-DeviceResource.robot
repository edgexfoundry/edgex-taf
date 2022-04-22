*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile DELETE Device Resource Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-delete-deviceresource-negative.log

*** Test Cases ***
ErrProfileResourceDELETE001 - Delete deviceResource by non-existent deviceResource name
    # non-existent deviceResource name
    Given Create A Device Profile Sample
    When Delete deviceResource By non-existent deviceResource name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileResourceDELETE002 - Delete deviceResource which profile used by device
    Given Create A Device Profile Sample With Associated Test-Device
    When Delete deviceResource By Name
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device By Name AND Delete Device Profile By Name

ErrProfileResourceDELETE003 - Delete deviceResource when StrictDeviceProfileChanges config is enabled
    # StrictDeviceProfileChanges config is true
    Given Create A Device Profile Sample
    And Set StrictDeviceProfileChanges to true
    When Delete deviceResource By Name
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Set writable.profileChange To false AND Delete Device Profile By Name
