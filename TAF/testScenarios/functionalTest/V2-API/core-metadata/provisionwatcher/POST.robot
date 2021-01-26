*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags

*** Variables ***
${SUITE}          Core Metadata Provision Watcher POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-provisionwatcher-post.log
${api_version}    v2

*** Test Cases ***
ProWatcherPOST001 - Create provision watcher
    When Create Provision Watchers
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms


