*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/system-agent/systemAgentAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          System Management Agent GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-get-negative.log

*** Test Cases ***
ErrSysMgmtGET001 - Query metrics of the given services containing non-existent services
    When Query Service Metrics  edgex-core-data  non-existent-service  edgex-core-command
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSysMgmtGET002 - Query configs of the given services containing non-existent services
    When Query Service Configs  edgex-support-scheduler  non-existent-service-1  non-existent-service-2
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSysMgmtGET003 - Query healths of the given services containing non-existent services
    When Query Service Healths  non-existent-service  edgex-core-metadata
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

