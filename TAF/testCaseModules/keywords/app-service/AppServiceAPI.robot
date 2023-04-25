*** Settings ***
Library   RequestsLibrary
Library   OperatingSystem
Library   TAF/testCaseModules/keywords/setup/edgex.py
Library   TAF/testCaseModules/keywords/setup/startup_checker.py
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Keywords ***
Setup Suite for App Service
    [Arguments]  ${appServiceUrl}
    Setup Suite
    Set Suite Variable  ${url}  ${appServiceUrl}
    Check app-service is available
    Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token

Check app-service is available
    ${port}=  Split String  ${url}  :
    Check service is available  ${port}[2]   /api/${API_VERSION}/ping

Suite Teardown for App Service
    Suite Teardown
    Run Teardown Keywords

Set ${service} Functions ${functions}
    ${path}=  Set variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/${service}/Writable/Pipeline/ExecutionOrder
    Update Service Configuration On Consul  ${path}  ${functions}

Set Transform Type ${type}
    ${path}=  Set variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/app-functional-tests/Writable/Pipeline/Functions/Transform/Parameters/Type
    Update Service Configuration On Consul  ${path}  ${type}

Set Compress Algorithm ${algorithm}
    ${path}=  Set variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/app-functional-tests/Writable/Pipeline/Functions/Compress/Parameters/Algorithm
    Update Service Configuration On Consul  ${path}  ${algorithm}

Set Encrypt Algorithm ${algorithm}
    ${path}=  Set variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/app-functional-tests/Writable/Pipeline/Functions/Encrypt/Parameters/Algorithm
    Update Service Configuration On Consul  ${path}  ${algorithm}

Trigger Function Pipeline With ${data}
    ${trigger_data}=  Run keyword if  '${data}' != 'Invalid Data'  set variable  Valid Data
    ...               ELSE  set variable  ${data}
    ${trigger_data}=  Load data file "app-service/trigger_data.json" and get variable "${trigger_data}"
    Set To Dictionary  ${trigger_data}  apiVersion=${API_VERSION}
    Run keyword if  '${data}' == 'No Matching DeviceName'
    ...    Run keywords  set to dictionary  ${trigger_data}[event]  deviceName=DeiveNotMatch
    ...    AND  set to dictionary  ${trigger_data}[event][readings][0]  deviceName=DeviceNotMatch
    Create Session  Trigger  url=${url}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Trigger  api/${API_VERSION}/trigger  json=${trigger_data}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}
