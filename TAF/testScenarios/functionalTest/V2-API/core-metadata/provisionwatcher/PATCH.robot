*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags

*** Variables ***
${SUITE}          Core Metadata Provision Watcher PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-patch.log
${api_version}    v2

*** Test Cases ***
ProWatcherPATCH001 - Update provision watcher
    Given Create Provision Watchers
    When Update Provision Watchers
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Provision Watcher Data Should Be Updated

ErrProWatcherPATCH001 - Update provision watcher with duplicate name
    Given Create Provision Watchers
    When Update Provision Watchers
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "409"
    And Item Index 1 Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPATCH002 - Update provision watcher with empty name
    Given Create Provision Watchers
    When Update Provision Watchers
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPATCH003 - Update provision watcher with empty identifiers
    Given Create Provision Watchers
    When Update Provision Watchers
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPATCH004 - Update provision watcher with autoEvents but no frequency
    Given Create Provision Watchers
    When Update Provision Watchers
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPATCH005 - Update provision watcher with autoEvents but no resource
    Given Create Provision Watchers
    When Update Provision Watchers
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherPATCH006 - Update provision watcher with invalid adminState
    Given Create Provision Watchers
    When Update Provision Watchers
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms




