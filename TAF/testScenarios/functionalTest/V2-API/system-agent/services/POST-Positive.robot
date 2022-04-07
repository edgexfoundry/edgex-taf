*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/system-agent/systemAgentAPI.robot
Library      TAF/testCaseModules/keywords/setup/edgex.py
Library      TAF/testCaseModules/keywords/setup/startup_checker.py
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Update MetricsMechanism To executor On Consul
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          System Management Agent POST Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-post-positive.log
${default_response_time_threshold}  10000

*** Test Cases ***
SysMgmtPOST001 - Start services by system management agent
    ${service_name_list}=  Create List  notifications  scheduler  # service names in compose file
    ${container_name_list}=  Create List  support-notifications  support-scheduler
    Given Stop Services  @{service_name_list}   # docker stop services (keyword in edgex.py)
    And Check Services Stopped  @{container_name_list}
    And Generate Multiple Operation Requests  start  @{container_name_list}
    When System Agent Controls Services  ${requests}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Services Have Been Started  @{service_name_list}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

SysMgmtPOST002 - Stop services by system management agent
    ${service_name_list}=  Create List  data  metadata  command
    ${container_name_list}=  Create List  core-data  core-metadata  core-command
    Given Services Have Been Started  @{service_name_list}
    And Generate Multiple Operation Requests  stop  @{container_name_list}
    When System Agent Controls Services  ${requests}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Check Services Stopped  @{container_name_list}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Restart Services  @{service_name_list}  # docker restart services (keyword in edgex.py)

SysMgmtPOST003 - Restart services by system management agent
    ${service_name_list}=  Create List  app-service-rules  device-rest
    ${container_name_list}=  Create List  app-rules-engine  device-rest
    ${app_path}=  Set Variable  /v1/kv/edgex/appservices/${CONSUL_CONFIG_VERSION}/app-rules-engine/Service/StartupMsg
    ${device_path}=  Set Variable  /v1/kv/edgex/devices/${CONSUL_CONFIG_VERSION}/device-rest/Service/StartupMsg
    ${keyword}=  Set Variable  service has been restart
    Given Update Service Configuration On Consul  ${app_path}  ${keyword}
    And Update Service Configuration On Consul  ${device_path}  ${keyword}
    And Generate Multiple Operation Requests  restart  @{container_name_list}
    When System Agent Controls Services  ${requests}
    And Sleep  5s  # to avoid time issue
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Services Have Been Restarted  ${keyword}  @{container_name_list}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Update Service Configuration On Consul  ${app_path}  app-rules-engine has Started
    ...         AND  Update Service Configuration On Consul  ${device_path}  device rest started
    ...         AND  Restart Services  @{service_name_list}  # docker restart services (keyword in edgex.py)

*** Keywords ***
Generate Multiple Operation Requests
    [Arguments]  ${action}  @{service_list}
    ${request_list}=  Create List
    FOR  ${service}  IN  @{service_list}
        ${request}=  Create Dictionary  apiVersion=v2  action=${action}  serviceName=${service}
        Append To List  ${request_list}  ${request}
    END
    Set Test Variable  ${requests}  ${request_list}

Services Have Been Started
    [Arguments]  @{service_list}
    FOR  ${service}  IN  @{service_list}
        Check Services Startup  ${service}
    END

Services Have Been Restarted
    [Arguments]  ${keyword}  @{service_list}
    FOR  ${service}  IN  @{service_list}
        ${timestamp}  Get current milliseconds epoch time
        Run Keyword If  '${service}' == 'device-rest'  sleep  3s
        ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service} 0
        ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
        ${return_log}=  Get Lines Containing String  str(${logs.stdout})  ${keyword}
        Should Not Be Empty  ${return_log}
    END
