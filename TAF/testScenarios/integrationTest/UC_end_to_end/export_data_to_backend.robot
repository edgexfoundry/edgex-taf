*** Settings ***
Library          BuiltIn
Library          Process
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Library          TAF/testCaseModules/keywords/setup/edgex.py
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource         TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource         TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown   Run Teardown Keywords
Force Tags       MessageQueue=redis

*** Variables ***
${SUITE}         Export data to backend
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/export_data_to_backend.log

*** Test Cases ***
Export001 - Export events/readings to HTTP Server
    ${handle}=  Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True   # Start HTTP Server
    Given Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Store Secret With HTTP Export To Vault
    And Create Device For device-virtual With Name http-export-device
    When Get device data by device http-export-device and command ${PREFIX}_GenerateDeviceValue_INT8_RW
    Then HTTP Server received event is the same with exported from service app-http-export
    [Teardown]  Run keywords  Delete device by name http-export-device
                ...           AND  Delete all events by age
                ...           AND  Terminate All Processes  kill=True

Export002 - Export events/readings to MQTT Server
    [Setup]  Run Keyword And Ignore Error  Stop Services  edgex-scalability-test-mqtt-export
    Given Start process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-subscriber.py edgex-events origin ${EX_BROKER_PORT} false 1 30 &   # Process for MQTT Subscriber
    ...                shell=True  stdout=${WORK_DIR}/TAF/testArtifacts/logs/mqtt-subscriber.log
    And Sleep  1s  # Waiting for above process is ready
    And Set Test Variable  ${device_name}  mqtt-export-device
    And Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Store Secret With MQTT Export To Vault
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT16_RW
    Then Device data has recevied by mqtt subscriber
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age

ExportErr001 - Export events/readings to unreachable HTTP backend
    Given Create Device For device-virtual With Name http-export-error-device
    When Get device data by device http-export-error-device and command ${PREFIX}_GenerateDeviceValue_INT32_RW
    Then No exported logs found on configurable application service  app-http-export
    [Teardown]  Run keywords  Delete device by name http-export-error-device
                ...           AND  Delete all events by age

ExportErr002 - Export events/readings to unreachable MQTT backend
    Given Run Keyword And Ignore Error  Stop Services  mqtt-broker  mqtt-taf-broker
    And Create Device For device-virtual With Name mqtt-export-error-device
    When Get device data by device mqtt-export-error-device and command ${PREFIX}_GenerateDeviceValue_INT64_RW
    Then No exported logs found on configurable application service  app-mqtt-export
    [Teardown]  Run keywords  Delete device by name mqtt-export-error-device
                ...           AND  Delete all events by age
                ...           AND  Run Keyword And Ignore Error  Restart Services  mqtt-broker  mqtt-taf-broker


*** Keywords ***
HTTP Server received event is the same with exported from service ${app_service}
    ${sent_data_length}=  Get exported data length from "${app_service}" service log
    run keyword if  '${sent_data_length}' == '${EMPTY}'  fail  No export log found on application service
    ${http_server_received}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/httpd-server.log  origin
    ${http_received_length}  run keyword if  r'''${http_server_received}''' == '${EMPTY}'  fail  No export log found on http-server
                             ...       ELSE  Get Length  ${http_server_received}
    should be equal  ${sent_data_length}  ${http_received_length}
    ...              The lengths are equal between HTTP Server received and app-service exported data

Get exported data length from "${app_service}" service log
    ${app_service_log}=  Catch logs for service "${app_service}" with keyword "Response status"
    ${app_service_log}=  Fetch From Right  ${app_service_log}  Sent
    ${sent_data_length}=  Fetch From Left  ${app_service_log}   bytes
    ${sent_data_length}  convert to number  ${sent_data_length}
    [Return]  ${sent_data_length}

Get device data by device ${device_name} and command ${command}
    Invoke Get command with params ds-pushevent=yes by device ${device_name} and command ${command}
    Should return status code "200"
    sleep  500ms

Device data has recevied by mqtt subscriber
    ${mqtt_broker_received}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/mqtt-subscriber.log  origin
    run keyword if  "${device_name}" not in """${mqtt_broker_received}"""
    ...             fail  No export log found on mqtt subscriber
    [Return]    ${mqtt_broker_received}

No exported logs found on configurable application service
    [Arguments]  ${app_service_name}
    ${current_timestamp}=  get current epoch time
    ${timestamp}=  evaluate  ${current_timestamp}-1
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${app_service_name} ${timestamp}
    ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    ${app_service_str}=  convert to string  ${logs.stdout}
    should not contain  ${app_service_str}  Sent data

Store Secret With ${service} Export To Vault
    ${APP_SERVICE_PORT}  Run Keyword If  '${service}' == 'MQTT'  Set Variable  ${APP_MQTT_EXPORT_PORT}
                         ...    ELSE IF  '${service}' == 'HTTP'  Set Variable  ${APP_HTTP_EXPORT_PORT}
    Set Test Variable  ${url}  http://${BASE_URL}:${APP_SERVICE_PORT}
    Store Secret Data With ${service} Export Auth
