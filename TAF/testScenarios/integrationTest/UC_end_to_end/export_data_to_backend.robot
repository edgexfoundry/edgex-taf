*** Settings ***
Library          BuiltIn
Library          Process
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Library          TAF/testCaseModules/keywords/setup/edgex.py
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource         TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                             AND  Deploy device service  device-virtual
Suite Teardown   Run keywords   Remove services  device-virtual
...                             AND  Delete device profile by name  Sample-Profile
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token

*** Variables ***
${SUITE}         Export data to backend
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/export_data_to_backend.log

*** Test Cases ***
Export001 - Export events/readings to HTTP Server
    [Tags]  SmokeTest
    ${handle}=  Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True   # Start HTTP Server
    Given Deploy services  app-service-http-export
    And Create device  create_device.json
    When Get device data by device "Test-Device" and command "GenerateDeviceValue_INT8_RW"
    Then HTTP Server received event is the same with exported from service "app-service-http-export"
    [Teardown]  Run keywords  Delete device by name Test-Device
                ...           AND  Remove all events
                ...           AND  remove services  app-service-http-export
                ...           AND  Terminate Process  ${handle}  kill=True

Export002 - Export events/readings to MQTT Server
    [Tags]  SmokeTest
    Given Deploy services  mqtt-broker
    And Start process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-subscriber.py &   # Process for MQTT Subscriber
    ...                shell=True  stdout=${WORK_DIR}/TAF/testArtifacts/logs/mqtt-subscriber.log
    And Deploy services  app-service-mqtt-export
    And Create device  create_device.json
    When Get device data by device "Test-Device" and command "GenerateDeviceValue_INT16_RW"
    Then Device data has recevied by mqtt subscriber
    And Found "Sent data to MQTT Broker" in service "app-service-mqtt-export" log
    [Teardown]  Run keywords  Delete device by name Test-Device
                ...           AND  Remove all events
                ...           AND  remove services  app-service-mqtt-export  mqtt-broker

ExportErr001 - Export events/readings to unreachable HTTP backend
    Given Deploy services  app-service-http-export
    And Create device  create_device.json
    When Get device data by device "Test-Device" and command "GenerateDeviceValue_INT32_RW"
    Then No exported logs found on configurable application service  app-service-http-export
    [Teardown]  Run keywords  Delete device by name Test-Device
                ...           AND  Remove all events
                ...           AND  remove services  app-service-http-export

ExportErr002 - Export events/readings to unreachable MQTT backend
    Given Deploy services  app-service-mqtt-export
    And Create device  create_device.json
    When Get device data by device "Test-Device" and command "GenerateDeviceValue_INT64_RW"
    Then No exported logs found on configurable application service  app-service-mqtt-export
    [Teardown]  Run keywords  Delete device by name Test-Device
                ...           AND  Remove all events
                ...           AND  remove services  app-service-mqtt-export


*** Keywords ***
HTTP Server received event is the same with exported from service "${app_service}"
    ${export_data_app_service}=  Get exported data from "${app_service}" service log
    run keyword if  '${export_data_app_service}' == '${EMPTY}'  fail  No export log found on application service
    ${http_server_received}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/httpd-server.log  origin
    run keyword if  '${http_server_received}' == '${EMPTY}'  fail  No export log found on http-server
    should contain  ${export_data_app_service}  ${http_server_received}  HTTP Server received data matched exported data

MQTT broker received event is the same with exported from service "${app_service}"
    ${mqtt_broker_received}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/mqtt-subscriber.log  origin
    run keyword if  '${mqtt_broker_received}' == '${EMPTY}' or '${mqtt_broker_received}' == 'None'
    ...             fail  No export log found on mqtt subscriber
    ${export_data_app_service}=  Get exported data from "${app_service}" service log
    run keyword if  '${export_data_app_service}' == '${EMPTY}'  fail  No export log found on MQTT application service
    should contain  ${export_data_app_service}  ${mqtt_broker_received}  MQTT broker received data matched exported data

Get exported data from "${app_service}" service log
    ${app_service_log}=  Catch logs for service "${app_service}" with keyword "origin"
    ${app_service_log}=  remove string  ${app_service_log}  \\
    ${fetch_export_data}=  fetch from right  ${app_service_log}  Sent data:
    ${export_data}=  replace string  ${fetch_export_data}  ]}"  ]}
    [Return]  ${export_data}

Get device data by device "${device_name}" and command "${command_name}"
    Invoke Get command by device name "${device_name}" and command name "${command_name}"
    Should return status code "200"
    sleep  500ms

Device data has recevied by mqtt subscriber
    ${mqtt_broker_received}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/mqtt-subscriber.log  origin
    run keyword if  '${mqtt_broker_received}' == '${EMPTY}' or '${mqtt_broker_received}' == 'None'
    ...             fail  No export log found on mqtt subscriber
    [Return]    ${mqtt_broker_received}

No exported logs found on configurable application service
    [Arguments]  ${app_service_name}
    ${current_timestamp}=  get current epoch time
    ${log_timestamp}=  evaluate  ${current_timestamp}-1
    ${app_service_log}=  run keyword if  '${app_service_name}'=='app-service-http-export'
                         ...             Get service logs since timestamp  ${app_service_name}  ${log_timestamp}
                         ...   ELSE IF   '${app_service_name}'=='app-service-mqtt-export'
                         ...             Get service logs since timestamp  ${app_service_name}  ${log_timestamp}
    log  ${app_service_log}
    ${app_service_str}=  convert to string  ${app_service_log}
    should not contain  ${app_service_str}  Sent data

