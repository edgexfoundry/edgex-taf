*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/system-agent/systemAgentAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          System Management Agent GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-get-positive.log

*** Test Cases ***
SysMgmtGET001 - Query metrics of the given services
    Set Test Variable  ${default_response_time_threshold}  3500   # normally exceed default 1200ms
    When Query Service Metrics  edgex-core-data  edgex-core-metadata  edgex-support-notifications
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200" And metrics
    And All Requested Services Should Return metrics
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

SysMgmtGET002 - Query config of the given services
    When Query Service Config  core-command  support-scheduler
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200" And config
    And All Requested Services Should Return config  # each service contains config object
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

SysMgmtGET003 - Query health of the given services
    When Query Service Health  core-data  core-metadata  core-command
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
All Requested Services Should Return ${property}
    ${count}=  Evaluate  len(${content})
    FOR  ${index}  IN RANGE  0  ${count}
        List Should Contain Value  ${service_list}  ${content}[${index}][serviceName]
        Run Keyword If  "${property}"=="metrics"  Should Be Equal As Strings  ${content}[${index}][metrics][Success]  True
        ...    ELSE IF  "${property}"=="config"  Should Be True  ${content}[${index}][config][config]
    END
