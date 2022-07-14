*** Settings ***
Resource         TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup      Run keywords  Setup Suite
...                       AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                       AND  Modify PersistOnError to true On Consul
Suite Teardown   Run keywords  Run Teardown Keywords
...                       AND  Modify PersistOnError to false On Consul
Force Tags       MessageQueue=redis

*** Variables ***
${SUITE}         Store And Forward Capability
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/export_store_and_forward.log

*** Test Cases ***
# PersistOnError=true and StoreAndForward.Enable=true
StoreAndForward001 - Stored data is exported after connecting to http server
    ${configurations}  Create Dictionary  Enabled=true  RetryInterval=3s  MaxRetryCount=3
    ${device_name}  Set Variable  store-device-1
    ${timestamp}  get current epoch time
    Given Set ${configurations} For app-http-export On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_UINT8_RW with ds-pushevent=yes
    Sleep  5s  # wait until retry fails
    Then Found Retry Log 2 Times In app-http-export Logs From ${timestamp}
    And Start HTTP Server And Received Exported Data Contains ${PREFIX}_GenerateDeviceValue_UINT8_RW
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age
                ...           AND  Terminate All Processes  kill=True

StoreAndForward002 - Stored data is cleared after the maximum configured retires
    ${configurations}  Create Dictionary  Enabled=true  RetryInterval=3s  MaxRetryCount=3
    ${device_name}  Set Variable  store-device-2
    ${timestamp}  get current epoch time
    Given Set ${configurations} For app-http-export On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT16_RW with ds-pushevent=yes
    Sleep  12s  # wait until retry fails
    Then Found Retry Log 3 Times In app-http-export Logs From ${timestamp}
    And Found Remove Log In app-http-export Logs From ${timestamp}
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age

StoreAndForward003 - Exporting data didn't retry when Writeable.StoreAndForward.Enabled is false
    ${configurations}  Create Dictionary  Enabled=false  RetryInterval=1s  MaxRetryCount=3
    ${device_name}  Set Variable  store-device-3
    ${timestamp}  get current epoch time
    Given Set ${configurations} For app-http-export On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT32_RW with ds-pushevent=yes
    Sleep  6s
    Then Found Retry Log 0 Times In app-http-export Logs From ${timestamp}
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age

StoreAndForward004 - Retry loop interval is set by the Writeable.StoreAndForward.RetryInterval config setting
    ${configurations}  Create Dictionary  Enabled=true  RetryInterval=2s  MaxRetryCount=4
    ${device_name}  Set Variable  store-device-4
    ${timestamp}  get current epoch time
    Given Set ${configurations} For app-http-export On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ds-pushevent=yes
    Sleep  12s  # wait until retry fails
    Then Found Retry Log 4 Times In app-http-export Logs From ${timestamp}
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age


StoreAndForward005 - Export retries will resume after application service is restarted
    ${configurations}  Create Dictionary  Enabled=true  RetryInterval=3s  MaxRetryCount=4
    ${device_name}  Set Variable  store-device-5
    Given Set ${configurations} For app-http-export On Consul
    And Create Device For device-virtual With Name ${device_name}
    When Get device ${device_name} read command ${PREFIX}_GenerateDeviceValue_UINT16_RW with ds-pushevent=yes
    And Waiting For Retrying Export
    ${timestamp}  get current epoch time
    And Restart Services  app-service-http-export
    Then Wait Until Keyword Succeeds  2x  5s  Found Retry Log From ${timestamp} After Restarting app-http-export
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age


*** Keywords ***
Set ${configurations} For ${service_name} On Consul
    ${config_key}  Get Dictionary Keys  ${configurations}  sort_keys=false
    ${config_value}  Get Dictionary Values  ${configurations}  sort_keys=false
    FOR  ${key}  ${value}  IN ZIP  ${config_key}  ${config_value}
        ${path}=  Set Variable  /v1/kv/edgex/appservices/${CONSUL_CONFIG_VERSION}/${service_name}/Writable/StoreAndForward/${key}
        Update Service Configuration On Consul  ${path}  ${value}
        Sleep  500ms
    END

Start HTTP Server And Received Exported Data Contains ${keyword}
    ${handle}  Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True
    Set Test Variable  ${handle}  ${handle}
    Sleep  3s
    ${http_server_received}  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/httpd-server.log  ${keyword}
    ${http_received_length}  run keyword if  r'''${http_server_received}''' == '${EMPTY}'  fail  No export log found on http-server
                             ...       ELSE  Get Line Count  ${http_server_received}
    Should Be Equal As Integers  1  ${http_received_length}

Found Retry Log ${number} Times In ${service_name} Logs From ${timestamp}
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service_name} ${timestamp}
    ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    ${retry_lines}  Get Lines Containing String  ${logs.stdout}.encode()  1 stored data items found for retrying
    ${retry_times}  Get Line Count  ${retry_lines}
    Should Be Equal As Integers  ${retry_times}  ${number}

Found Remove Log In ${service_name} Logs From ${timestamp}
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service_name} ${timestamp}
    ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    ${retry_lines}  Get Lines Containing String  ${logs.stdout}.encode()  1 stored data items will be removed post retry
    ${retry_times}  Get Line Count  ${retry_lines}
    Should Be Equal As Integers  ${retry_times}  1

Modify PersistOnError to ${value} On Consul
    ${path}  Set Variable  /v1/kv/edgex/appservices/${CONSUL_CONFIG_VERSION}/app-http-export/Writable/Pipeline/Functions/HTTPExport/Parameters/PersistOnError
    Update Service Configuration On Consul  ${path}  ${value}
    Restart Services  app-service-http-export
    Sleep  4s

Waiting For Retrying Export
    Run Keyword If  "${ARCH}" == "x86_64"  Sleep  5s

Found Retry Log From ${timestamp} After Restarting ${service_name}
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service_name} ${timestamp}
    ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    ${retry_lines}  Get Lines Containing String  ${logs.stdout}.encode()  1 stored data items found for retrying
    Should Not Be Empty   ${retry_lines}
