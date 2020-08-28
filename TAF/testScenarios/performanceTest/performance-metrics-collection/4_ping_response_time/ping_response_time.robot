*** Settings ***
Documentation   Measure the ping response time
...             Measure the ping response time of ping API for each edgex service
...             Measure the ping execution time from creating event by device-virtual until export-distro send event to a MQTT broker
Library         REST
Library         TAF/testCaseModules/keywords/setup/edgex.py
Library         TAF/testCaseModules/keywords/performance-metrics-collection//PingResponse.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup     Run keywords    Setup Suite
                ...             AND  Deploy EdgeX  -  PerformanceMetrics
Suite Teardown  Shutdown services

*** Variables ***
${SUITE}          Measure the ping response time
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/performance-metric-collection-ping.log


*** Test Cases ***
Measure the ping response time of ping API for core-data service
    @{DATA_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:48080/api/v1/ping        headers={ "Accept": "text/plain" }
        Response time is less than threshold setting  core-data  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${DATA_RES_LIST}     ${res}
    END

    Record response   edgex-core-data   ${DATA_RES_LIST}

Ping API for core-metadata service
    @{METADATA_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:48081/api/v1/ping        headers={ "Accept": "text/plain" }
        Response time is less than threshold setting  core-metadata  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${METADATA_RES_LIST}     ${res}
    END
    Record response   edgex-core-metadata        ${METADATA_RES_LIST}

Ping API for core-command service
    @{COMMAND_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:48082/api/v1/ping        headers={ "Accept": "text/plain" }
        Response time is less than threshold setting  core-command  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${COMMAND_RES_LIST}     ${res}
    END
    Record response   edgex-core-command        ${COMMAND_RES_LIST}

Ping API for support-scheduler service
    @{SCHEDULER_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:48085/api/v1/ping        headers={ "Accept": "text/plain" }
        Response time is less than threshold setting  support-scheduler  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${SCHEDULER_RES_LIST}     ${res}
    END
    Record response   edgex-support-scheduler        ${SCHEDULER_RES_LIST}

Ping API for support-notifications service
    @{NOTIFICATIONS_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:48060/api/v1/ping        headers={ "Accept": "text/plain" }
        Response time is less than threshold setting  support-notifications  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${NOTIFICATIONS_RES_LIST}     ${res}
    END
    Record response   edgex-support-notifications        ${NOTIFICATIONS_RES_LIST}

Ping API for sys-mgmt-agent service
    @{SYS_MGMT_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:48090/api/v1/ping        headers={ "Accept": "text/plain" }
        Response time is less than threshold setting  sys-mgmt-agent  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${SYS_MGMT_RES_LIST}     ${res}
    END
    Record response   edgex-sys-mgmt-agent        ${SYS_MGMT_RES_LIST}

Ping API for device-rest service
    @{DEVICE_REST_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:49986/api/v1/ping        headers={ "Accept": "text/plain" }
        Response time is less than threshold setting  device-rest  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${DEVICE_REST_RES_LIST}     ${res}
    END
    Record response   edgex-device-rest        ${DEVICE_REST_RES_LIST}

Ping API for app-service service
    @{APP_SERVICE_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:48100/api/v1/ping        headers={ "Accept": "text/plain" }
        ${response_time}=    evaluate  ${res}[seconds] * 1000
        Response time is less than threshold setting  app-service  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${APP_SERVICE_RES_LIST}     ${res}
    END
    Record response   edgex-app-service-configurable-rules        ${APP_SERVICE_RES_LIST}

Ping API for device-virtual service
    @{DEVICE_VIRTUAL_RES_LIST}=  Create List
    FOR  ${index}  IN RANGE  0  ${PING_RES_LOOP_TIME}
        ${res} =    GET   http://localhost:49990/api/v1/ping        headers={ "Accept": "text/plain" }
        Response time is less than threshold setting  device-virtual  ${res}  ${PING_RES_THRESHOLD}
        APPEND TO LIST  ${DEVICE_VIRTUAL_RES_LIST}     ${res}
    END
    Record response   edgex-device-virtual        ${DEVICE_VIRTUAL_RES_LIST}

Show all services response time
    show full response time report

Show aggregation report
    show the aggregation report

*** Keywords ***
Response time is less than threshold setting
    [Arguments]  ${service}  ${response}  ${threshold_setting}
    ${response_time}=    evaluate  ${response}[seconds] * 1000
    ${compare_result}  evaluate   ${response_time} < ${threshold_setting}
     RUN KEYWORD IF  '${compare_result}' == 'False'
     ...             Fail  Response time is over than ${threshold_setting}ms when ping ${service}
