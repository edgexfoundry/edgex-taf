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

*** Variables ***
${SUITE}         Export data to backend
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/export_data_to_backend.log

*** Test Cases ***
Export001 - Export events/readings to HTTP Server
    [Tags]  SmokeTest
    ${handle}=  Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True   # Start HTTP Server
    Given Create Device For device-virtual With Name http-export-device
    When Get device data by device http-export-device and command ${PREFIX}_GenerateDeviceValue_INT8_RW
    Then HTTP Server received event is the same with exported from service app-http-export
    [Teardown]  Run keywords  Delete device by name http-export-device
                ...           AND  Delete all events by age
                ...           AND  Terminate Process  ${handle}  kill=True

Export002 - Export events/readings to MQTT Server
    [Tags]  SmokeTest
    [Setup]  Stop Services  scalability-test-mqtt-export
    Given Start process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-subscriber.py arg &   # Process for MQTT Subscriber
    ...                shell=True  stdout=${WORK_DIR}/TAF/testArtifacts/logs/mqtt-subscriber.log
    And Set Test Variable  ${device_name}  mqtt-export-device
    And Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Store Secret With MQTT Export To Vault
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT16_RW
    Then Device data has recevied by mqtt subscriber
    And Found "Sent data to MQTT Broker" in service "app-mqtt-export" log
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...           AND  Delete all events by age

ExportErr001 - Export events/readings to unreachable HTTP backend
    Given Create Device For device-virtual With Name http-export-error-device
    When Get device data by device http-export-error-device and command ${PREFIX}_GenerateDeviceValue_INT32_RW
    Then No exported logs found on configurable application service  app-http-export
    [Teardown]  Run keywords  Delete device by name http-export-error-device
                ...           AND  Delete all events by age

ExportErr002 - Export events/readings to unreachable MQTT backend
    Given Stop Services  mqtt-broker
    And Create Device For device-virtual With Name mqtt-export-error-device
    When Get device data by device mqtt-export-error-device and command ${PREFIX}_GenerateDeviceValue_INT64_RW
    Then No exported logs found on configurable application service  app-mqtt-export
    [Teardown]  Run keywords  Delete device by name mqtt-export-error-device
                ...           AND  Delete all events by age
                ...           AND  Restart Services  mqtt-broker


*** Keywords ***
HTTP Server received event is the same with exported from service ${app_service}
    ${export_data_app_service}=  Get exported data from "${app_service}" service log
    run keyword if  """${export_data_app_service}""" == '${EMPTY}'  fail  No export log found on application service
    ${http_server_received}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/httpd-server.log  origin
    run keyword if  """${http_server_received}""" == '${EMPTY}'  fail  No export log found on http-server
    should contain  ${export_data_app_service}  ${http_server_received}  HTTP Server received data matched exported data

Get exported data from "${app_service}" service log
    ${app_service_log}=  Catch logs for service "${app_service}" with keyword "origin"
    ${app_service_log}=  remove string  ${app_service_log}  \\
    ${fetch_export_data}=  fetch from right  ${app_service_log}  Sent data:
    ${export_data}=  replace string  ${fetch_export_data}  ]}"  ]}
    [Return]  ${export_data}

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
    ${log_timestamp}=  evaluate  ${current_timestamp}-1
    ${app_service_log}=  Get service logs since timestamp  ${app_service_name}  ${log_timestamp}
    log  ${app_service_log}
    ${app_service_str}=  convert to string  ${app_service_log}
    should not contain  ${app_service_str}  Sent data

Store Secret With MQTT Export To Vault
    Set Test Variable  ${url}  http://${BASE_URL}:${APP_MQTT_EXPORT_PORT}
    Store Secret Data With MQTT Export Auth
