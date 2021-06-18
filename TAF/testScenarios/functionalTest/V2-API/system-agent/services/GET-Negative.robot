*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/system-agent/systemAgentAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Update MetricsMechanism To executor On Consul
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          System Management Agent GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/system-agent-get-negative.log

*** Test Cases ***
ErrSysMgmtGET001 - Query metrics of the given services containing non-existent services
    Set Test Variable  ${default_response_time_threshold}  3500   # normally exceed default 1200ms
    When Query Service Metrics  core-data  non-existent-service  support-notifications
    Then Should Return Status Code "207"
    And Should Retrun 200 and metrics For Existent Services And 500 And metrics=None For Non-Existent Services
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
    Given Update MetricsMechanism To direct-service On Consul
    When Query Service Metrics  non-existent-service  core-metadata
    Then Should Return Status Code "207"
    And Should Retrun 200 And config For Existent Services And 404 And metrics=None For Non-Existent Services
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Should Retrun 200 And ${property} For Existent Services And ${error_code} And ${property}=None For Non-Existent Services
    FOR  ${index}  IN RANGE  0  len(${content})
         Run Keyword If  "non-existent-service" in "${content}[${index}][serviceName]"  Run Keywords
         ...             Should Be True  ${content}[${index}][statusCode]==${error_code}
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
