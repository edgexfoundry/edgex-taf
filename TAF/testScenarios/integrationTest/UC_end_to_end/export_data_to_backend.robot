*** Settings ***
Library          BuiltIn
Library          TAF.utils.src.setup.setup_teardown
Library          TAF.utils.src.setup.edgex
Library          TAF.utils.src.setup.external_service
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/coreDataAPI.robot
Resource         TAF/testCaseModules/keywords/deviceServiceAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND
...                             Deploy device service  device-virtual
Suite Teardown   Run keywords   Remove services  device-virtual
...                             AND
...                             Delete device profile by name Sample-Profile

*** Variables ***
${SUITE}         Export data to backend
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/export_data_to_backend.log

*** Test Cases ***
Export001 - Export events/readings to HTTP Server
    Given Start http server
    And Deploy services  app-service-http-export
    And Create device  create_device.json
    When Get device data by device "Test-Device" and command "GenerateDeviceValue_INT8_RW"
    Then HTTP Server received event is the same with exported from service "app-service-http-export"
    And Exported events/readings from "app-service-http-export" has marked as PUSHED
    [Teardown]  Run keywords  Delete device by name Test-Device
                ...           AND
                ...           remove services  app-service-http-export

Export002 - Export events/readings to MQTT Server
    [Tags]  skipped
    Given Deploy device service
    And Start MQTT Server
    And Deploy configurable application service with mqtt-export profile
    And Create device
    When Retrieve device data by get command from the device
    Then Reading have exported to MQTT Server
    And The exported reading existed on core-data and mark as Pushed
    And Related log found on core-data
    And Related log found on configurable application service

ExportErr001 - Export events/readings to unreachable HTTP backend
    [Tags]  skipped
    Given Deploy device service
    And Deploy configurable application service with unreachable http backend
    And Create device
    When Retrieve device data by get command from the device
    Then The exported data existed on core-data and doesn't mark as Pushed
    And Related logs found on core-data
    And Related logs found on configurable application service

ExportErr002 - Export events/readings to unreachable MQTT backend
    [Tags]  skipped
    Given Deploy device service
    And Deploy configurable application service with unreachable mqtt backend
    And Create device
    When Retrieve device data by get command from the device
    Then The exported data existed on core-data and doesn't mark as Pushed
    And Related logs found on core-data
    And Related logs found on configurable application service


*** Keywords ***
Exported events/readings from "${app_service}" has marked as PUSHED
    ${export_data_app_service}=  Get exported data from "${app_service}" service log
    ${export_data_json}=  evaluate  json.loads('''${export_data_app_service}''')  json
    ${event_statuscode}  ${event_response}  Query event by event id "${export_data_json}[id]"
    run keyword if  ${event_statuscode} != 200  fail  no event found
    ${event_json}=  evaluate  json.loads('''${event_response}''')  json
    ${pushed}=  convert to string  ${event_json}[pushed]
    ${pushed_length}=  get length  ${pushed}
    should be equal as integers  ${pushed_length}  13  The event didn't export to backend

HTTP Server received event is the same with exported from service "${app_service}"
    ${export_data_app_service}=  Get exported data from "${app_service}" service log
    run keyword if  '${export_data_app_service}' == '${EMPTY}'  fail  No export log found on application service
    ${http_server_received}=  grep file  ${WORK_DIR}/TAF/testArtifacts/logs/httpd-server.log  origin
    run keyword if  '${http_server_received}' == '${EMPTY}'  fail  No export log found on http-server
    should contain  ${export_data_app_service}  ${http_server_received}  HTTP Server received data matched exported data

Catch logs for service "${service_name}" with keyword "${keyword}"
    ${current_timestamp}=  Get current epoch time
    ${log_timestamp}=  evaluate   int(${current_timestamp}-1)
    ${service_log}=  Get service logs since timestamp  ${service_name}  ${log_timestamp}
    ${return_log}=  Get Lines Containing String  str(${service_log})  ${keyword}
    [Return]  ${return_log}

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


