*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/system-agent/systemAgentAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          System Management Agent GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-get-positive.log

*** Test Cases ***
SysMgmtGET001 - Query metrics of the given services
    When Query Service Metrics  edgex-core-data  edgex-core-metadata  edgex-support-notifications
    Then Should Return Status Code "200" And metrics
    And All Requested Services Should Return metrics  # each service contains metrics object
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

SysMgmtGET002 - Query configs of the given services
    When Query Service Configs  edgex-core-command  edgex-support-scheduler
    Then Should Return Status Code "200" And config
    And All Requested Services Should Return config  # each service contains config object
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

SysMgmtGET003 - Query healths of the given services
    When Query Service Healths  edgex-core-data  edgex-core-metadata  edgex-core-command
    Then Should Return Status Code "200" And health
    And All Requested Services Should Return healthy  # each service returns string "healthy"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

