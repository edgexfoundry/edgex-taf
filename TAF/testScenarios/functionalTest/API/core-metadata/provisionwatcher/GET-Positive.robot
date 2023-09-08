*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Provision Watcher GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-get-positive.log

*** Test Cases ***
# /provisionwatcher/all
ProWatcherGET001 - Query all provision watcher
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers
    Then Should Return Status Code "200" And provisionWatchers
    And totalCount Should be 4  # device-onvif-camera will auto create a provision watcher
    And Should Be True  len(${content}[provisionWatchers]) == 4
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherGET002 - Query all provision watcher with offset
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers With offset=1
    Then Should Return Status Code "200" And provisionWatchers
    And Should Return Content-Type "application/json"
    And totalCount Should be 4  # device-onvif-camera will auto create a provision watcher
    And Should Be True  len(${content}[provisionWatchers]) == 3
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherGET003 - Query all provision watcher with limit
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers With limit=2
    Then Should Return Status Code "200" And provisionWatchers
    And totalCount Should be 4  # device-onvif-camera will auto create a provision watcher
    And Should Return Content-Type "application/json"
    And Should Be True  len(${content}[provisionWatchers]) == 2
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherGET004 - Query all provision watcher with specified labels
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  labels=@{EMPTY}
    And Append To List  ${provisionwatcher}[2][provisionwatcher][labels]  new_label
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers with labels=simple
    Then Should Return Status Code "200" And provisionWatchers
    And Should Return Content-Type "application/json"
    And totalCount Should be 2
    And Should Be True  len(${content}[provisionWatchers]) == 2
    And Provision Watchers Should Be Linked To Specified Label: simple
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

# /provisionwatcher/name/{name}
ProWatcherGET005 - Query provision watcher by name
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Create Provision Watcher ${provisionwatcher}
    When Query Provision Watchers By Name  Test-Provision-Watcher
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherGET006 - Query provision watcher by chinese name
    Given Set Test Variable  ${test_proWatcher_name}  自动寻找監測-1
    And Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  name=${test_proWatcher_name}
    And Create Provision Watcher ${provisionwatcher}
    When Query Provision Watchers By Name  ${test_proWatcher_name}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Strings  ${test_proWatcher_name}  ${content}[provisionWatcher][name]
    [Teardown]  Run Keywords  Delete Multiple Provision Watchers By Names
                ...           Test-Provision-Watcher  ${test_proWatcher_name}  Test-Provision-Watcher-AutoEvents
                ...      AND  Delete multiple device services by names
                ...           Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
                ...      AND  Delete multiple device profiles by names
                ...           Test-Profile-1  Test-Profile-2  Test-Profile-3

# /provisionwatcher/profile/name/{name}
ProWatcherGET007 - Query provision watcher by specified device profile
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers By profileName  Test-Profile-1
    Then Should Return Status Code "200" And provisionWatchers
    And Should Return Content-Type "application/json"
    And totalCount Should be 1
    And Should Be True  len(${content}[provisionWatchers]) == 1
    And Provision Watchers Should Be Linked To Specified Device Profile: Test-Profile-1
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherGET008 - Query provision watcher by specified device profile with offset
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher][discoveredDevice]  profileName=Test-Profile-1
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher][discoveredDevice]  profileName=Test-Profile-1
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers By profileName Test-Profile-1 With offset=1
    Then Should Return Status Code "200" And provisionWatchers
    And Should Return Content-Type "application/json"
    And totalCount Should be 3
    And Should Be True  len(${content}[provisionWatchers]) == 2
    And Provision Watchers Should Be Linked To Specified Device Profile: Test-Profile-1
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherGET009 - Query provision watcher by specified device profile with limit
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher][discoveredDevice]  profileName=Test-Profile-1
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher][discoveredDevice]  profileName=Test-Profile-1
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers By profileName Test-Profile-1 With limit=2
    Then Should Return Status Code "200" And provisionWatchers
    And Should Return Content-Type "application/json"
    And totalCount Should be 3
    And Should Be True  len(${content}[provisionWatchers]) == 2
    And Provision Watchers Should Be Linked To Specified Device Profile: Test-Profile-1
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

# /provisionwatcher/service/name/{name}
ProWatcherGET010 - Query provision watcher by specified device service
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers By serviceName  Device-Service-${index}-1
    Then Should Return Status Code "200" And provisionWatchers
    And Should Return Content-Type "application/json"
    And totalCount Should be 1
    And Should Be True  len(${content}[provisionWatchers]) == 1
    And Provision Watchers Should Be Linked To Specified Device Service: Device-Service-${index}-1
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherGET011 - Query provision watcher by specified device service with offset
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  serviceName=Device-Service-${index}-1
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher]  serviceName=Device-Service-${index}-1
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers By serviceName Device-Service-${index}-1 With offset=2
    Then Should Return Status Code "200" And provisionWatchers
    And Should Return Content-Type "application/json"
    And totalCount Should be 3
    And Should Be True  len(${content}[provisionWatchers]) == 1
    And Provision Watchers Should Be Linked To Specified Device Service: Device-Service-${index}-1
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherGET012 - Query provision watcher by specified device service with limit
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  serviceName=Device-Service-${index}-1
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher]  serviceName=Device-Service-${index}-1
    And Create Provision Watcher ${provisionwatcher}
    When Query All Provision Watchers By serviceName Device-Service-${index}-1 With limit=2
    Then Should Return Status Code "200" And provisionWatchers
    And Should Return Content-Type "application/json"
    And totalCount Should be 3
    And Should Be True  len(${content}[provisionWatchers]) == 2
    And Provision Watchers Should Be Linked To Specified Device Service: Device-Service-${index}-1
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

*** Keywords ***
Provision Watchers Should Be Linked To Specified Label: ${label}
    ${provisionwatchers}=  Set Variable  ${content}[provisionWatchers]
    FOR  ${item}  IN  @{provisionwatchers}
        List Should Contain Value  ${item}[labels]  ${label}
    END

Provision Watchers Should Be Linked To Specified Device ${associated}: ${associated_name}
    ${provisionwatchers}=  Set Variable  ${content}[provisionWatchers]
    ${associated}=  Convert To Lower Case  ${associated}
    FOR  ${item}  IN  @{provisionwatchers}
        Run Keyword If  "${associated}" == "profile"  Should Be Equal  ${item}[discoveredDevice][${associated}Name]  ${associated_name}
        ...    ELSE IF  "${associated}" == "service"  Should Be Equal  ${item}[${associated}Name]  ${associated_name}
        ...       ELSE  Fail  No Field With ${associated}Name Found
    END
