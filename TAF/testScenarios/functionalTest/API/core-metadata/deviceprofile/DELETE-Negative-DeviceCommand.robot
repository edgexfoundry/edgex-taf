*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile DELETE DeviceCommand Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-delete-devicecommand-negative.log

*** Test Cases ***
ErrProfileCommandDELETE001 - Delete deviceCommand by non-existent profile name
    # non-existent profile name
    When Delete deviceCommand By non-existent profile name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileCommandDELETE002 - Delete deviceCommand by non-existent command name
    # non-existent deviceCommand name
    Given Create A Device Profile Sample
    When Delete deviceCommand By non-existent deviceCommand name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileCommandDELETE003 - Delete deviceCommand which profile used by device
    Given Create A Device Profile Sample With Associated Test-Device
    When Delete deviceCommand By Name
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device By Name AND Delete Device Profile By Name

ErrProfileCommandDELETE004 - Delete deviceCommand when StrictDeviceProfileChanges config is enabled
    # StrictDeviceProfileChanges config is true
    Given Create A Device Profile Sample
    And Set StrictDeviceProfileChanges to true
    When Delete deviceCommand By Name
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Set writable.profileChange To false AND Delete Device Profile By Name
