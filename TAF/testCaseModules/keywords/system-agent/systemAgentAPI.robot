*** Settings ***
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Variables ***
${systemAgentUrl}  ${URI_SCHEME}://${BASE_URL}:${SYS_MGMT_AGENT_PORT}

*** Keywords ***
Query Service Metrics
    [Arguments]  @{service_list}
    Set Test Variable  ${service_list}  ${service_list}
    ${services}=  Evaluate  ",".join(@{service_list})
    Create Session  System Agent  url=${systemAgentUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  System Agent  api/${API_VERSION}/system/metrics  params=services=${services}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Query Service Config
    [Arguments]  @{service_list}
    Set Test Variable  ${service_list}  ${service_list}
    ${services}=  Evaluate  ",".join(@{service_list})
    Create Session  System Agent  url=${systemAgentUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  System Agent  api/${API_VERSION}/system/config  params=services=${services}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Query Service Health
    [Arguments]  @{service_list}
    Set Test Variable  ${service_list}  ${service_list}
    ${services}=  Evaluate  ",".join(@{service_list})
    Create Session  System Agent  url=${systemAgentUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  System Agent  api/${API_VERSION}/system/health  params=services=${services}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

System Agent Controls Services
    [Arguments]  ${requests}
    Create Session  System Agent  url=${systemAgentUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  System Agent  api/${API_VERSION}/system/operation  json=${requests}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}

Update MetricsMechanism To ${value} On Consul
    ${mechanism_path}=  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/sys-mgmt-agent/MetricsMechanism
    Update Service Configuration On Consul  ${mechanism_path}  ${value}
    Restart Services  system
