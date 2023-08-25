*** Settings ***
Documentation    URIs were set on compose file
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown   Run Teardown Keywords
Force Tags       MessageBus=redis

*** Variables ***
${SUITE}         URI for files with username-passward in URI

*** Test Cases ***
URI001-Test UoM URI with username-passward in URI
    Given Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Update core-metadata Configuration On Consul
    When Query UoM
    Then Should Contain  ${content}[uom][units][weights][values]  uritest

URI002-Test configuration file, device profiles, devices and provision watchers with username-password in URI
    ${metadata_list}  Create List  profile  device  provisionWatcher
    ${name_list}  Create List  onvif-camera  Camera001  Generic-Onvif-Provision-Watcher
    Given Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Update device-onvif-camera Configuration On Consul
    FOR  ${metadata}  ${name}  IN ZIP  ${metadata_list}  ${name_list}
        When Run Keyword If  '${metadata}' == 'profile'  Query Device Profile By Name  ${name}
             ...    ELSE IF  '${metadata}' == 'device'  Query Device By Name  ${name}
             ...    ELSE IF  '${metadata}' == 'provisionWatcher'  Query Provision Watchers By Name  ${name}
        Then Run Keyword If  '${metadata}' == 'device'  Should Contain  ${content}[${metadata}][description]  uritest
             ...       ELSE  Should Contain  ${content}[${metadata}][labels]  uritest
    END

URI003-Test Common configuration file with username-password in URI
    [Setup]  Skip If  $SECURITY_SERVICE_NEEDED == 'true'
    ${path}  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/core-command/Writable/LogLevel
    Given Set Test Variable  ${url}  ${coreCommandUrl}
    FOR  ${validate}  IN  config  consul
        When Run Keyword If  "${validate}" == "config"  Query Config
             ...    ELSE IF  "${validate}" == "consul"  Query Service Configuration On Consul  ${path}
        Then Run Keyword If  "${validate}" == "config"  Should Return Status Code "200" And config
             ...    ELSE IF  "${validate}" == "consul"  Should return status code "404"
    END

*** Keywords ***
Store Secret With HTTP Server To ${service}
    ${url}  Run Keyword If  "${service}" == "core-metadata"  Set Variable  ${coreMetadataUrl}
            ...    ELSE IF  "${service}" == "device-onvif-camera"  Set Variable  ${URI_SCHEME}://${BASE_URL}:${ONVIF_CAMERA_PORT}
            ...       ELSE  Fail  Incorrect service
    ${auth_value}  Evaluate  base64.b64encode(bytes('${HTTP_USER}:${HTTP_PASSWD}', 'UTF-8'))  modules=base64
    ${secrets_data}=  Load data file "all-services/secrets_data.json" and get variable "HTTP Server Auth"
    Set To Dictionary  ${secrets_data}  apiVersion=${API_VERSION}
    Set To Dictionary  ${secrets_data}[secretData][2]  value=Basic ${auth_value}
    Create Session  Secrets  url=${url}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  POST On Session  Secrets  api/${API_VERSION}/secret  json=${secrets_data}  headers=${headers}
    ...       expected_status=201

Update core-metadata Configuration On Consul
    ${path}  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/core-metadata/UoM/UoMFile
    ${value}  Set Variable  http://httpd-auth:80/files/uom.yaml?edgexSecretName=httpserver
    Store Secret With HTTP Server To core-metadata
    Update Service Configuration On Consul  ${path}  ${value}
    Restart Services  core-metadata

Update device-onvif-camera Configuration On Consul
    ${var_name_list}  Create List  ProfilesDir  DevicesDir  ProvisionWatchersDir
    ${file_list}  Create List  profile  device  provisionwatcher
    Store Secret With HTTP Server To device-onvif-camera
    FOR  ${var_name}  ${file}  IN ZIP  ${var_name_list}  ${file_list}
        ${path}  Set Variable  ${CONSUL_CONFIG_BASE_ENDPOINT}/device-onvif-camera/Device/${var_name}
        ${value}  Set Variable  http://httpd-auth:80/files/${file}.json?edgexSecretName=httpserver
        Update Service Configuration On Consul  ${path}  ${value}
    END
    Restart Services  device-onvif-camera
