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
${SUITE}          System Management Agent POST Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-post-negative.log
${metadata_path}  /v1/kv/edgex/core/${CONSUL_CONFIG_VERSION}/core-metadata/Service/StartupMsg
${keyword}        service has been restart

*** Test Cases ***
ErrSysMgmtPOST001 - Control services containing undefined services by system management agent
    Set Test Variable  ${default_response_time_threshold}  10000
    Given Stop Core Data And Reset Core Metadata StartupMsg
    And Generate Multiple Operation Requests Containing Undefined Services
    When System Agent Controls Services  ${requests}
    Then Should Return Status Code "207"
    And Should Retrun 200 For Existent Services And 404 For Unknown Services
    And Should Return Content-Type "application/json"
    And Some Services Have Been Started/Stopped/Restarted
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Update Service Configuration On Consul  ${metadata_path}  This is the EdgeX Core Metadata Microservice
    ...         AND  Restart Services  command  metadata

ErrSysMgmtPOST002 - Control services containing invalid request by system management agent
    Given Generate multiple operation requests containing invalid requests
    When System Agent Controls Services  ${requests}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Stop Core Data And Reset Core Metadata StartupMsg
    Stop Services  data
    Check Services Stopped  edgex-core-data
    Update Service Configuration On Consul  ${metadata_path}  ${keyword}
    Restart Services  metadata

Generate Multiple Operation Requests Containing Undefined Services
    ${start_request}=  Create Dictionary  apiVersion=v2  action=start  serviceName=edgex-core-data
    ${stop_request}=  Create Dictionary  apiVersion=v2  action=stop  serviceName=edgex-core-command
    ${restart_request}=  Create Dictionary  apiVersion=v2  action=restart  serviceName=edgex-core-metadata
    ${unknown_start_request}=  Create Dictionary  apiVersion=v2  action=start  serviceName=Unknown-Service-1
    ${unknown_stop_request}=  Create Dictionary  apiVersion=v2  action=stop  serviceName=Unknown-Service-2
    ${unknown_restart_request}=  Create Dictionary  apiVersion=v2  action=stop  serviceName=Unknown-Service-3
    ${request_list}=  Create List  ${start_request}  ${stop_request}  ${restart_request}
    ...                            ${unknown_start_request}  ${unknown_stop_request}  ${unknown_restart_request}
    Set Test Variable  ${requests}  ${request_list}

Should Retrun 200 For Existent Services And 404 For Unknown Services
    FOR  ${index}  IN RANGE  0  len(${content})
         Run Keyword If  "Unknown-Service" in "${content}[${index}][serviceName]"
         ...             Should Be True  ${content}[${index}][statusCode]==500
         ...       ELSE  Should Be True  ${content}[${index}][statusCode]==200
    END

Some Services Have Been Started/Stopped/Restarted
    Found "${keyword}" in service "edgex-core-metadata" log
    Check Services Startup  data
    Check Services Stopped  edgex-core-command

Generate multiple operation requests containing invalid requests
    ${start_request}=  Create Dictionary  apiVersion=v2  action=start  serviceName=edgex-core-data
    ${stop_request}=  Create Dictionary  apiVersion=v2  action=stop  serviceName=edgex-core-command
    ${restart_request}=  Create Dictionary  apiVersion=v2  action=restart  serviceName=edgex-core-metadata
    ${invalid_request}=  Create Dictionary  apiVersion=v2  action=Invalid  serviceName=edgex-support-notifications
    ${request_list}=  Create List  ${start_request}  ${stop_request}  ${restart_request}  ${invalid_request}
    Set Test Variable  ${requests}  ${request_list}
