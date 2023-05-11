*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Provision Watcher PATCH Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-patch.log

*** Test Cases ***
ProWatcherPATCH001 - Update provision watcher
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Provision Watcher Should Be Updated
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH001 - Update provision watcher with empty name
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  name=${EMPTY}
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH002 - Update provision watcher with empty identifiers
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  identifiers=&{EMPTY}
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH003 - Update provision watcher with autoEvents but no interval
    ${autoEvents}=  Set autoEvents values  ${EMPTY}  false  DeviceValue_Boolean_RW
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating
    And Set To Dictionary  ${provisionwatcher}[4][provisionwatcher][discoveredDevice]  autoEvents=${autoEvents}
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH004 - Update provision watcher with autoEvents but no resource
    ${autoEvents}=  Set autoEvents values  24h  false  ${EMPTY}
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating
    And Set To Dictionary  ${provisionwatcher}[4][provisionwatcher][discoveredDevice]  autoEvents=${autoEvents}
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPATCH005 - Update provision watcher with invalid adminState
    Given Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher]  adminState=Invalid
    When Update Provision Watchers ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample


*** Keywords ***
Create Provision Watchers And Generate Multiple Provision Watchers Sample For Updating
    Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    Create Provision Watcher ${provisionwatcher}
    ${labels}=  Create List  provision-watcher-example  provision-watcher-update
    ${update_labels}=  Create Dictionary  name=Test-Provision-Watcher  labels=${labels}
    ${update_adminstate}=  Create Dictionary  name=Test-Provision-Watcher-Locked  adminState=UNLOCKED
    ${identifiers}=  Load data file "core-metadata/identifiers.json" and get variable "identifiers"
    Set To Dictionary  ${identifiers}  address=0.0.0.0  port=123
    ${update_identifiers}=  Create Dictionary  name=Test-Provision-Watcher-AutoEvents  identifiers=${identifiers}
    ${ports}=  Create List  111  222  333
    ${blockingIdentifiers}=  Load data file "core-metadata/identifiers.json" and get variable "blockingIdentifiers"
    Set To Dictionary  ${blockingIdentifiers}  ports=${ports}
    ${update_blockingIdentifiers}=  Create Dictionary  name=Test-Provision-Watcher-Locked  blockingIdentifiers=${blockingIdentifiers}
    ${autoEvent}=  Set autoEvents values  24h  false  ${PREFIX}_DeviceValue_Boolean_RW
    ${autoEvents}=  Create List  ${autoEvent}
    ${autoEvents_dict}  Create Dictionary  autoEvents=${autoEvents}
    ${update_autoEvents}=  Create Dictionary  name=Test-Provision-Watcher-AutoEvents  discoveredDevice=${autoEvents_dict}
    Set To Dictionary  ${update_adminstate}  serviceName=Device-Service-${index}-3
    Generate Provision Watchers  ${update_labels}  ${update_adminstate}  ${update_identifiers}
    ...         ${update_blockingidentifiers}  ${update_autoEvents}

Provision Watcher Should Be Updated
    ${list}  Create List  Test-Provision-Watcher  Test-Provision-Watcher-Locked  Test-Provision-Watcher-AutoEvents
    ${expected_keys}  Create List  name  labels  adminState  identifiers  discoveredDevice  serviceName
    ${discoveredDevice_expected_keys}  Create List  profileName
    FOR  ${name}  IN  @{list}
        Query Provision Watchers By Name  ${name}
        ${keys}  Get Dictionary Keys  ${content}[provisionWatcher]
        ${discoveredDevice_keys}  Get Dictionary Keys  ${content}[provisionWatcher][discoveredDevice]
        List Should Contain Sub List  ${keys}  ${expected_keys}
        List Should Contain Sub List  ${discoveredDevice_keys}  ${discoveredDevice_expected_keys}
        Run Keyword If  "${name}" == "Test-Provision-Watcher"  Run Keywords
        ...             List Should Contain Value  ${content}[provisionWatcher][labels]  provision-watcher-update
        ...       AND   List Should Contain Value  ${content}[provisionWatcher][labels]  provision-watcher-example
        Run Keyword If  "${name}" == "Test-Provision-Watcher-Locked"  Run Keywords
        ...             Should Be Equal  ${content}[provisionWatcher][adminState]  UNLOCKED
        ...        AND  Should Be Equal  ${content}[provisionWatcher][blockingIdentifiers][ports][0]  111
        ...        AND  Should Be Equal  ${content}[provisionWatcher][serviceName]  Device-Service-${index}-3
        Run Keyword If  "${name}" == "Test-Provision-Watcher-AutoEvents"  Run Keywords
        ...             Should Be Equal  ${content}[provisionWatcher][identifiers][address]  0.0.0.0
        ...        AND  Should Be Equal  ${content}[provisionWatcher][discoveredDevice][autoEvents][0][interval]  24h
    END

