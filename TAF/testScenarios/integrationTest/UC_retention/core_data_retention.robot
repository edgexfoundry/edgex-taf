*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run keywords  Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
             ...      AND  Delete all events by age
             ...      AND  Set Core-Data Retention  ${interval}  ${maxCap}  ${minCap}  ${duration}
             ...      AND  Update Service Configuration  ${DATA_CONSOL_PATH}/Writable/LogLevel  DEBUG
Suite Teardown  Run Keywords  Set Core-Data Retention  10m  -1  1  168h
                ...      AND  Update Service Configuration  ${DATA_CONSOL_PATH}/Writable/LogLevel  INFO
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}          core-data Retention
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_data_retention.log
${DATA_CONSOL_PATH}  /core-data
${maxCap}  4
${minCap}  1
${interval}  2s
${duration}  2s

*** Test Cases ***
CoreDataRetention001 - core-data retention is executed if reading count is over DefaultMaxCap value
    Given Set Test Variable  ${deviceName}  data-retention-device1
    And Create Events With AutoEvent Interval 100ms
    And Sleep  3s
    And Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    Then Stored Event Count Should Less Than ${maxCap} and Large Than ${minCap}
    [Teardown]  Delete all events by age

CoreDataRetention002 - core-data retention is not executed if reading count is less than DefaultMaxCap value
    Given Set Test Variable  ${deviceName}  data-retention-device2
    And Create Events With AutoEvent Interval 1s
    And Sleep  3s
    Then No Purge Log Found in core-data
    And Stored Event Count Should Less Than ${maxCap} and Large Than ${minCap}
    [Teardown]  Delete all events by age

*** Keywords ***
Set Core-Data Retention
    [Arguments]  ${interval}  ${maxCap}  ${minCap}  ${duration}
    ${keys}  Create List  Interval  DefaultMaxCap  DefaultMinCap  DefaultDuration
    ${values}  Create List  ${interval}  ${maxCap}  ${minCap}  ${duration}
    FOR  ${key}  ${value}  IN ZIP  ${keys}  ${values}
        ${path}=  Set Variable  ${DATA_CONSOL_PATH}/Retention/${key}
        Update Service Configuration  ${path}  ${value}
    END
    Restart Services  core-data

Create ${range} events with ${command}
    FOR  ${INDEX}  IN RANGE  ${range}
        Get device data by device ${device_name} and command ${command} with ds-pushevent=true
    END
    sleep  500ms


Stored Event Count Should Less Than ${max} and Large Than ${min}
    ${time}  Get Current Nanoseconds Epoch Time
    ${compare_time}  Evaluate  ${time} - 3000000000
    ${count}  Set Variable  ${0}
    Query all events
    FOR  ${INDEX}  IN RANGE  len(${content}[events])
        IF  ${content}[events][${INDEX}][origin] <= ${compare_time}
            ${count}  Evaluate  ${count} + 1
        END
    END
    Should Be True  ${min} <= ${count} <= ${max}

Get Readings Ids From Event API
    ${ids}  Create List
    FOR  ${EVENT_INDEX}  IN RANGE  len(${content}[events])
        FOR  ${READING_INDEX}  IN RANGE  len(${content}[events][${EVENT_INDEX}][readings])
            Append To List  ${ids}  ${content}[events][${EVENT_INDEX}][readings][${READING_INDEX}][id]
        END
    END
    RETURN  ${ids}

Purge Log Found in ${service}
    ${logs}  Get Log in ${service}
    Should Contain  ${logs}  purge events by duration
    Delete Device By Name ${deviceName}

No Purge Log Found in ${service}
    ${logs}  Get Log in ${service}
    Should Not Contain  ${logs}  purge events by duration
    Delete Device By Name ${deviceName}

Get Log in ${service}
    ${current_time}  Get current epoch time
    ${timestamp}  Evaluate  ${current_time}-4
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service} ${timestamp}
             ...     shell=True  stderr=STDOUT  output_encoding=UTF-8  timeout=5s
    Log  ${logs.stdout}
    RETURN  ${logs.stdout}

Create Events With AutoEvent Interval ${interval}
    Create AutoEvent Device  ${interval}  false  ${PREFIX}_GenerateDeviceValue_INT8_RW
    Sleep  1s
    Set To Dictionary    ${Device}[0][device][autoEvents][0]  interval=1s
    Update Devices ${Device}
    Query all events
    Get Log in core-data
