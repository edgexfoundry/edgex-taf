*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags

*** Variables ***
${SUITE}          Core Metadata Provision Watcher POST Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-post-negative.log
${api_version}    v2

*** Test Cases ***
ErrProWatcherPOST001 - Create provision watcher with empty name
    When Create Provision Watchers
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPOST002 - Create provision watcher with duplicate name
    When Create Provision Watchers
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "201" And id
    And Item Index 1 Should Contain Status Code "409"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPOST003 - Create provision watcher with empty identifiers
    When Create Provision Watchers
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPOST004 - Create provision watcher with non-existent profile name
    [Tags]  skipped
    # Waiting for implementation
    When Create Provision Watchers
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 1 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPOST005 - Create provision watcher with non-existent service name
    [Tags]  skipped
    # Waiting for implementation
    When Create Provision Watchers
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 1 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPOST006 - Create provision watcher with autoEvents but no frequency
    When Create Provision Watchers
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPOST007 - Create provision watcher with autoEvents but no resource
    When Create Provision Watchers
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPOST008 - Create provision watcher with invalid adminState
    # adminState is not locked or unlocked
    When Create Provision Watchers
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
