*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Provision Watcher PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-patch.log
${api_version}    v2

*** Test Cases ***
ProWatcherPATCH001 - Update provision watcher
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating Data
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Provision Watcher Data Should Be Updated
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH001 - Update provision watcher with duplicate name
    [Tags]  skipped  # Not implement
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating Data
    And Set To Dictionary  ${provisionwatcher}[0][provisionwatcher]  name=Test-Provision-Watcher-Locked
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "409"
    And Item Index 1 Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH002 - Update provision watcher with empty name
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating Data
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  name=${EMPTY}
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH003 - Update provision watcher with empty identifiers
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating Data
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  identifiers=&{EMPTY}
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH004 - Update provision watcher with autoEvents but no frequency
    ${autoEvents}=  Set autoEvents values  ${EMPTY}  false  DeviceValue_Boolean_RW
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating Data
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher]  autoEvents=${autoEvents}
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH005 - Update provision watcher with autoEvents but no resource
    ${autoEvents}=  Set autoEvents values  24h  false  ${EMPTY}
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating Data
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher]  autoEvents=${autoEvents}
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH006 - Update provision watcher with invalid adminState
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating Data
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher]  adminState=Invalid
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample


*** Keywords ***
Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating ${type}
    Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    Create Provision Watcher ${provisionwatcher}
    ${labels}=  Create List  provision-watcher-example  provision-watcher-update
    ${update_labels}=  Create Dictionary  name=Test-Provision-Watcher  labels=${labels}  apiVersion=${api_version}
    ${update_adminstate}=  Create Dictionary  name=Test-Provision-Watcher-Locked  adminState=UNLOCKED  apiVersion=${api_version}
    ${identifiers}=  Load data file "core-metadata/identifiers.json" and get variable "identifiers"
    Set To Dictionary  ${identifiers}  address=0.0.0.0  port=123
    ${update_identifiers}=  Create Dictionary  name=Test-Provision-Watcher-AutoEvents  identifiers=${identifiers}  apiVersion=${api_version}
    ${ports}=  Create List  111  222  333
    ${blockingIdentifiers}=  Load data file "core-metadata/identifiers.json" and get variable "blockingIdentifiers"
    Set To Dictionary  ${blockingIdentifiers}  ports=${ports}
    ${update_blockingIdentifiers}=  Create Dictionary  name=Test-Provision-Watcher-Locked  blockingIdentifiers=${blockingIdentifiers}  apiVersion=${api_version}
    ${autoEvent}=  Set autoEvents values  24h  false  DeviceValue_Boolean_RW
    ${autoEvents}=  Create List  ${autoEvent}
    ${update_autoEvents}=  Create Dictionary  name=Test-Provision-Watcher-AutoEvents  autoEvents=${autoEvents}  apiVersion=${api_version}
    Run Keyword If  "${type}" != "Data"  run keywords  Set To Dictionary  ${update_adminstate}  adminState=LOCKED
    ...        AND  Set To Dictionary  ${update_adminstate}  serviceName=Device-Service-${index}-3
    Generate Provision Watchers  ${update_labels}  ${update_adminstate}  ${update_identifiers}
    ...         ${update_blockingidentifiers}  ${update_autoEvents}

Provision Watcher ${type} Should Be Updated
    ${list}=  Create List  Test-Provision-Watcher  Test-Provision-Watcher-Locked  Test-Provision-Watcher-AutoEvents
    ${expected_keys}=  Create List  name  labels  adminState  identifiers  serviceName  profileName
    FOR  ${provisionwatcher}  IN  @{list}
        Query Provision Watchers By Name  ${provisionwatcher}
        ${keys}=  Get Dictionary Keys  ${content}[provisionWatcher]
        List Should Contain Sub List  ${keys}  ${expected_keys}
        Run Keyword If  "${type}" == "Data" and "${provisionwatcher}" == "Test-Provision-Watcher"  Run Keywords
        ...             List Should Contain Value  ${content}[provisionWatcher][labels]  provision-watcher-update
        ...       AND   List Should Contain Value  ${content}[provisionWatcher][labels]  provision-watcher-example
        Run Keyword If  "${type}" == "Data" and "${provisionwatcher}" == "Test-Provision-Watcher-Locked"  Run Keywords
        ...             Should Be Equal  ${content}[provisionWatcher][adminState]  UNLOCKED
        ...        AND  Should Be Equal  ${content}[provisionWatcher][blockingIdentifiers][ports][0]  111
        ...    ELSE IF  "${provisionwatcher}" == "Test-Provision-Watcher-Locked"
        ...             Should Be Equal  ${content}[provisionWatcher][serviceName]  Device-Service-${index}-3
        Run Keyword If  "${type}" == "Data" and "${provisionwatcher}" == "Test-Provision-Watcher-AutoEvents"  Run Keywords
        ...             Should Be Equal  ${content}[provisionWatcher][identifiers][address]  0.0.0.0
        ...        AND  Should Be Equal  ${content}[provisionWatcher][autoEvents][0][frequency]  24h
    END

