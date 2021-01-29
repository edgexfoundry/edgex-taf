*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags

*** Variables ***
${SUITE}          Core Metadata Provision Watcher GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-get-positive.log
${api_version}    v2

*** Test Cases ***
# /provisionwatcher/all
ProWatcherGET001 - Query all provision watcher
    Given Create Multiple Provision Watchers
    When Query All Provision Watchers
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And The Number Of Provision Watchers Should Be The Same As Created
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ProWatcherGET002 - Query all provision watcher with offset
    Given Create Multiple Provision Watchers
    When Query All Provision Watchers
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ProWatcherGET003 - Query all provision watcher with limit
    Given Create Multiple Provision Watchers
    When Query All Provision Watchers
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Skipped Records Should Be The Same As Limit Setting
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ProWatcherGET004 - Query all provision watcher with specified labels
    Given Create Multiple Provision Watchers
    When Query All Provision Watchers
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Provision Watchers Should Be Linked To Specified Label
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /provisionwatcher/name/{name}
ProWatcherGET005 - Query provision watcher by name
    Given Create Multiple Provision Watchers
    When Query Provision Watchers By Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /provisionwatcher/profile/name/{name}
ProWatcherGET006 - Query provision watcher by specified device profile
    Given Create Multiple Provision Watchers
    When Query Provision Watchers By Profile Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Provision Watchers Should Be Linked To Specified Profile
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ProWatcherGET007 - Query provision watcher by specified device profile with offset
    Given Create Multiple Provision Watchers
    When Query Provision Watchers By Profile Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ProWatcherGET008 - Query provision watcher by specified device profile with limit
    Given Create Multiple Provision Watchers
    When Query Provision Watchers By Profile Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Skipped Records Should Be The Same As Limit Setting
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /provisionwatcher/service/name/{name}
ProWatcherGET009 - Query provision watcher by specified device service
    Given Create Multiple Provision Watchers
    When Query Provision Watchers By Service Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Provision Watchers Should Be Linked To Specified Service
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ProWatcherGET010 - Query provision watcher by specified device service with offset
    Given Create Multiple Provision Watchers
    When Query Provision Watchers By Service Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Returned Number Should Be The Same As Setting
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ProWatcherGET011 - Query provision watcher by specified device service with limit
    Given Create Multiple Provision Watchers
    When Query Provision Watchers By Service Name
    Then Should Return Status Code "200"
    And Should Have Content-Type "application/json"
    And Skipped Records Should Be The Same As Limit Setting
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms


