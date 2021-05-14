*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Provision Watcher POST Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-post-negative.log

*** Test Cases ***
ErrProWatcherPOST001 - Create provision watcher with empty name
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  name=${EMPTY}
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProWatcherPOST002 - Create provision watcher with duplicate name
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Create Provision Watcher ${provisionwatcher}
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "409"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ErrProWatcherPOST003 - Create provision watcher with empty identifiers
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  identifiers=&{EMPTY}
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProWatcherPOST004 - Create provision watcher with non-existent profile name
    [Tags]  skipped
    # Waiting for implementation
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  profileName=Invalid
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 1 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProWatcherPOST005 - Create provision watcher with non-existent service name
    [Tags]  skipped
    # Waiting for implementation
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  serviceName=Invalid
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 1 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProWatcherPOST006 - Create provision watcher with autoEvents but no interval
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher][autoEvents][0]  interval=${EMPTY}
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProWatcherPOST007 - Create provision watcher with autoEvents but no sourceName
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher][autoEvents][0]  sourceName=${EMPTY}
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrProWatcherPOST008 - Create provision watcher with invalid adminState
    # adminState is not locked or unlocked
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  adminState=Invalid
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3
