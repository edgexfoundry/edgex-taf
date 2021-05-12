*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/system-agent/systemAgentAPI.robot
Library      TAF/testCaseModules/keywords/setup/edgex.py
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          System Management Agent POST Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-post-positive.log

*** Test Cases ***
SysMgmtPOST001 - Start services by system management agent
    Given Stop Services  edgex-support-notifications  edgex-support-scheduler   # docker stop services (keyword in edgex.py)
    And Services Have Been Stopped
    When System Agent Starts Services  edgex-support-notifications  edgex-support-scheduler
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Services Have Been Started
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

SysMgmtPOST002 - Stop services by system management agent
    When System Agent Stops Services  edgex-core-data  edgex-core-metadata  edgex-core-command
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Services Have Been Stopped
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Restart Services  edgex-core-data  edgex-core-metadata  edgex-core-command  # docker restart services (keyword in edgex.py)

SysMgmtPOST003 - Restart services by system management agent
    When System Agent Restarts Services  edgex-core-data  edgex-core-metadata  edgex-core-command  edgex-support-scheduler
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Services Have Been Restarted
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

SysMgmtPOST004 - Update service configurations by system management agent
    When System Agent Updates Service Configurations
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Services Have Been Updated
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Update Service Configurations To Original Settings