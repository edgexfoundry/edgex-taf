*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/system-agent/systemAgentAPI.robot
Library      TAF/testCaseModules/keywords/setup/edgex.py
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          System Management Agent POST Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-post-negative.log

*** Test Cases ***
ErrSysMgmtPOST001 - Start services containing undefined services by system management agent
    Given Stop Services  edgex-support-notifications  # docker stop services (keyword in edgex.py)
    And Services Have Been Stopped
    When System Agent Starts Services  Unknown-Service-1  edgex-support-notifications  Unknown-Service-2
    Then Should Return Status Code "207"
    And Item Index 1 Should Contain Status Code "200"
    And Item Index 0,2 Should Contain Status Code "404"
    And Some Services Have Been Started
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Restart Services  edgex-support-notifications  # docker restart services (keyword in edgex.py)

ErrSysMgmtPOST002 - Stop services containing undefined services by system management agent
    When System Agent Stops Services  edgex-core-data  Unknown-Service
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "200"
    And Item Index 1 Should Contain Status Code "404"
    And Some Services Have Been Stopped
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Restart Services  edgex-core-data  # docker restart services (keyword in edgex.py)

ErrSysMgmtPOST003 - Restart services containing undefined services by system management agent
    When System Agent Restarts Services  edgex-core-command  edgex-support-scheduler  Unknown-Service
    Then Should Return Status Code "207"
    And Item Index 0,1 Should Contain Status Code "200"
    And Item Index 2 Should Contain Status Code "404"
    And Some Services Have Been Restarted
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSysMgmtPOST004 - Update service configurations containing undefined services by system management agent
    When System Agent Updates Service Configuration
    Then Should Return Status Code "207"
    And Some Items Should Contain Status Code "404"
    And Some Service Has Been Updated
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Update Service Configurations To Original Settings

ErrSysMgmtPOST005 - Update service configurations containing invalid configs by system management agent
    When System Agent Updates Service Configuration
    Then Should Return Status Code "207"
    And Some Items Should Contain Status Code "400"
    And Some Service Has Been Updated
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Update Service Configurations To Original Settings
