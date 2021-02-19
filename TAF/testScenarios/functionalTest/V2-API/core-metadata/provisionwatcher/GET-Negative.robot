*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags   v2-api

*** Variables ***
${SUITE}          Core Metadata Provision Watcher GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-get-negative.log
${api_version}    v2

*** Test Cases ***
# /provisionwatcher/all
ErrProWatcherGET001 - Query all provision watcher with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Provision Watchers With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherGET002 - Query all provision watcher with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Provision Watchers With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /provisionwatcher/name/{name}
ErrProWatcherGET003 - Query provision watcher by non-existent provision watcher name
    When Run Keyword And Expect Error  *  Query Provision Watchers By Name  Non-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /provisionwatcher/profile/name/{name}
ErrProWatcherGET004 - Query provision watcher by profile name with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Provision Watchers By profileName Test-Profile-1 With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherGET005 - Query provision watcher by profile name with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Provision Watchers By profileName Test-Profile-1 With limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /provisionwatcher/service/name/{name}
ErrProWatcherGET006 - Query provision watcher by service name with non-int value on offset
    When Run Keyword And Expect Error  *  Query All Provision Watchers By serviceName Test-Device-Service With offset=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProWatcherGET007 - Query provision watcher by service name with non-int value on limit
    When Run Keyword And Expect Error  *  Query All Provision Watchers By serviceName Test-Device-Service with limit=Invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms





