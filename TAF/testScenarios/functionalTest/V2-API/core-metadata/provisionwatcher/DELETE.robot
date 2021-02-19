*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Core Metadata Provision Watcher DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-delete.log
${api_version}    v2

*** Test Cases ***
ProWatcherDELETE001 - Delete provision watcher
    Given Create A Provision Watcher Sample With Associated Test-Device-Service And Test-Profile-1
    When Delete provision watcher by name Test-Provision-Watcher
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete device service by name  Test-Device-Service
    ...                  AND  Delete device profile by name  Test-Profile-1

ErrProWatcherDELETE001 - Delete a non-existent provision watcher
    When Delete provision watcher by name non-exist-provision-watcher
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
