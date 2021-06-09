*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/system-agent/systemAgentAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          System Management Agent GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-get-negative.log

*** Test Cases ***
ErrSysMgmtGET001 - Query metrics of the given services containing non-existent services
    Set Test Variable  ${default_response_time_threshold}  3500   # normally exceed default 1200ms
    When Query Service Metrics  edgex-core-data  non-existent-service  edgex-support-notifications
    Then Should Return Status Code "207"
    And Should Retrun Success=True For Existent Services And Success=False For Non-Existent Services
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSysMgmtGET002 - Query config of the given services containing non-existent services
    When Query Service Config  support-scheduler  non-existent-service-1  non-existent-service-2
    Then Should Return Status Code "207"
    And Should Retrun 200 And config For Existent Services And 404 And config=None For Non-Existent Services
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSysMgmtGET003 - Query health of the given services containing non-existent services
    When Query Service Health  non-existent-service  core-metadata
    Then Should Return Status Code "207"
    And Should Retrun 200 For Existent Services And 404 For Non-Existent Services
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrSysMgmtGET004 - Query metrics of the given services containing non-existent services with MetricsMechanism=direct-service
    ${mechanism_path}=  Set Variable  /v1/kv/edgex/core/${CONSUL_CONFIG_VERSION}/sys-mgmt-agent/MetricsMechanism
    Given Update Service Configuration On Consul  ${mechanism_path}  direct-service
    And Restart Services  system
    When Query Service Metrics  non-existent-service  core-metadata
    Then Should Return Status Code "207"
    And Should Retrun 200 And config For Existent Services And 404 And metrics=None For Non-Existent Services
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Update Service Configuration On Consul  ${mechanism_path}  executor
    ...                  AND  Restart Services  system

*** Keywords ***
Should Retrun Success=True For Existent Services And Success=False For Non-Existent Services
    FOR  ${index}  IN RANGE  0  len(${content})
         Run Keyword If  "non-existent-service" in "${content}[${index}][serviceName]"  Run Keywords
         ...             Should Be True  ${content}[${index}][statusCode]==500
         ...             AND  Should Be Equal As Strings  ${content}[${index}][metrics][Success]  False
         ...       ELSE  Run Keywords  Should Be True  ${content}[${index}][statusCode]==200
         ...             AND  Should Be Equal As Strings  ${content}[${index}][metrics][Success]  True
    END


Should Retrun 200 And config For Existent Services And 404 And ${property}=None For Non-Existent Services
    FOR  ${index}  IN RANGE  0  len(${content})
         Run Keyword If  "non-existent-service" in "${content}[${index}][serviceName]"  Run Keywords
         ...             Should Be True  ${content}[${index}][statusCode]==404
         ...             AND  Should Not Be True  ${content}[${index}][${property}]
         ...       ELSE  Run Keywords  Should Be True  ${content}[${index}][statusCode]==200
         ...             AND  Should Be True  ${content}[${index}][${property}]
    END

Should Retrun 200 For Existent Services And 404 For Non-Existent Services
    FOR  ${index}  IN RANGE  0  len(${content})
         Run Keyword If  "non-existent-service" in "${content}[${index}][serviceName]"
         ...             Should Be True  ${content}[${index}][statusCode]==404
         ...       ELSE  Should Be True  ${content}[${index}][statusCode]==200
    END
