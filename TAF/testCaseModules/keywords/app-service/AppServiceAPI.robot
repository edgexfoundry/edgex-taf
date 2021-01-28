*** Settings ***
Library   RequestsLibrary
Library   OperatingSystem
Library   TAF/testCaseModules/keywords/setup/edgex.py
Library   TAF/testCaseModules/keywords/setup/startup_checker.py
Library   TAF/testCaseModules/keywords/consul/consul.py
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot

*** Keywords ***
Setup Suite for App Service
    [Arguments]  ${appServiceUrl}  ${app_service_name}
    Setup Suite
    Set Suite Variable  ${url}  ${appServiceUrl}
    Set Suite Variable  ${app_service_name}  ${app_service_name}
    Deploy services  ${app_service_name}
    Check app-service is available
    Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token

Check app-service is available
    ${port}=  Split String  ${url}  :
    Check service is available  ${port}[2]   /api/v2/ping

Suite Teardown for App Service
    Suite Teardown
    Remove services  ${app_service_name}
    Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token

Set Functions ${functions}
    ${path}=  Set variable  /v1/kv/edgex/appservices/1.0/AppService-functional-tests/Writable/Pipeline/ExecutionOrder
    Modify consul config  ${path}  ${functions}
    sleep  1

Trigger Function Pipeline With ${data}
    ${trigger_data}=  Run keyword if  '${data}' != 'Invalid Data'  set variable  Valid Data
    ...               ELSE  set variable  ${data}
    ${trigger_data}=  Load data file "app-service/trigger_data.json" and get variable "${trigger_data}"
    Run keyword if  '${data}' == 'No Matching DeviceName'
    ...    Run keywords  set to dictionary  ${trigger_data}[event]  deviceName=DeiveNotMatch
    ...    AND  set to dictionary  ${trigger_data}[event][readings][0]  deviceName=DeviceNotMatch
    Create Session  Trigger  url=${url}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Trigger  api/${api_version}/trigger  json=${trigger_data}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 200  log to console  ${content}

Store Secret Data With ${data}
    ${secrets_data}=  Load data file "app-service/secrets_data.json" and get variable "${data}"
    Create Session  Secrets  url=${url}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Secrets  api/${api_version}/secret  json=${secrets_data}  headers=${headers}
    ...       expected_status=any
    Set Response to Test Variables  ${resp}
    Run keyword if  ${response} != 201  log to console  ${content}
    ...             ELSE  Run Keywords  Set test variable  ${secrets_path}  ${secrets_data}[path]
    ...             AND  Set test variable  ${secrets_key}  ${secrets_data}[secretData][0][key]
    ...             AND  Set test variable  ${secrets_value}  ${secrets_data}[secretData][0][value]



