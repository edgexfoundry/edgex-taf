*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Provision Watcher POST Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-post-positive.log

*** Test Cases ***
ProWatcherPOST001 - Create provision watcher with same device service
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  serviceName=Device-Service-${index}-1
    And Set To Dictionary  ${provisionwatcher}[2][provisionwatcher]  serviceName=Device-Service-${index}-1
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherPOST002 - Create provision watcher with different device service
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherPOST003 - Create provision watcher with uuid
    # Request body contains uuid
    ${random_uuid}=  Evaluate  str(uuid.uuid4())
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1]  requestId=${random_uuid}
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Be Equal  ${content}[1][requestId]  ${random_uuid}
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample

ProWatcherPOST004 - Create provision watcher with non-existent service name
    Given Create Multiple Profiles/Services And Generate Multiple Provision Watchers Sample
    And Set To Dictionary  ${provisionwatcher}[1][provisionwatcher]  serviceName=Invalid
    When Create Provision Watcher ${provisionwatcher}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Provision Watchers Sample, Profiles Sample And Services Sample
