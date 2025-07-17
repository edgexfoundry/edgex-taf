*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run keywords  Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
             ...      AND  Delete all events by age
             ...      AND  Update Service Configuration  ${DATA_CONSOL_PATH}/Writable/LogLevel  DEBUG
Suite Teardown  Run Keywords  Set Core-Data Retention In Registry Service  10m  -1  1  168h
                ...      AND  Update Service Configuration  ${DATA_CONSOL_PATH}/Writable/LogLevel  INFO
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}          core-data Retention
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_data_retention.log
${DATA_CONSOL_PATH}  /core-data
${DEFAULT_MAXCAP}  5
${DEFAULT_MINCAP}  3
${DEFAULT_INTERVAL}  2s
${DEFAULT_DURATION}  2
${TEST_COMMAND_1}  ${PREFIX}_GenerateDeviceValue_INT8_RW
${TEST_COMMAND_2}  ${PREFIX}_GenerateDeviceValue_INT16_RW

*** Test Cases ***
CoreDataRetention001 - Retention is executed if event count is over DefaultMaxCap value
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  ${DEFAULT_MAXCAP}  ${DEFAULT_MINCAP}  ${DEFAULT_DURATION}s
    And Set Test Variable  ${deviceName}  data-retention-device1
    When Create Events With AutoEvent Interval 100ms
    And Sleep  3s
    Then Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    And Stored Event Count Over Duration Should Correct  ${DEFAULT_MAXCAP}  ${DEFAULT_MINCAP}  ${DEFAULT_DURATION}
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Set Core-Data Retention In Registry Service  10m  -1  1  168h
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention002 - Retention is not executed if event count is less than DefaultMaxCap value
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  ${DEFAULT_MAXCAP}  ${DEFAULT_MINCAP}  ${DEFAULT_DURATION}s
    And Set Test Variable  ${deviceName}  data-retention-device2
    When Create Events With AutoEvent Interval 1s
    And Sleep  3s
    Then No Purge Log Found in core-data
    And Stored Event Count Over Duration Should Correct  ${DEFAULT_MAXCAP}  1  ${DEFAULT_DURATION}
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Set Core-Data Retention In Registry Service  10m  -1  1  168h
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention003 - DefaultMaxCap is disabled if the value is -1
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  -1  ${DEFAULT_MINCAP}  ${DEFAULT_DURATION}s
    And Set Test Variable  ${deviceName}  data-retention-device3
    When Create Events With AutoEvent Interval 300ms
    And Sleep  3s
    Then Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    And Stored Event Count Over Duration Should Correct  -1  ${DEFAULT_MINCAP}  ${DEFAULT_DURATION}
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Set Core-Data Retention In Registry Service  10m  -1  1  168h
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention004 - DefaultMinCap is disabled if the value is -1
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  ${DEFAULT_MAXCAP}  -1  ${DEFAULT_DURATION}s
    And Set Test Variable  ${deviceName}  data-retention-device4
    When Create Events With AutoEvent Interval 500ms
    And Sleep  3s
    Then Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    And Stored Event Count Over Duration Should Correct  ${DEFAULT_MAXCAP}  -1  ${DEFAULT_DURATION}
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Set Core-Data Retention In Registry Service  10m  -1  1  168h
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention005 - Disable retention when interval=0s
    Given Set Core-Data Retention In Registry Service  0s  ${DEFAULT_MAXCAP}  ${DEFAULT_MINCAP}  ${DEFAULT_DURATION}s
    And Set Test Variable  ${deviceName}  data-retention-device5
    When Create Events With AutoEvent Interval 300ms
    And Sleep  3s
    Then No Purge Log Found in core-data
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Set Core-Data Retention In Registry Service  10m  -1  1  168h
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention006 - Use retention setting from the autoevent
    ${retention}  Create Dictionary  maxCap=${8}  minCap=${5}  duration=1s
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  -1  1  168h
    And Set Test Variable  ${deviceName}  data-retention-device6
    When Create Events With AutoEvent Retention  100ms  ${retention}
    And Sleep  1s
    Then Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    And Retention For sourceName ${TEST_COMMAND_2} Should Be Skipped
    And Stored Event Count Over Duration Should Correct  10  5  1
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Set Core-Data Retention In Registry Service  10m  -1  1  168h
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention007 - No MaxCap is set in the autoevent
    ${retention}  Create Dictionary  minCap=${3}  duration=1s
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  10  1  168h
    And Set Test Variable  ${deviceName}  data-retention-device7
    When Create Events With AutoEvent Retention  100ms  ${retention}
    And Sleep  1s
    Then Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    And Retention For sourceName ${TEST_COMMAND_2} Should Be Skipped
    And Stored Event Count Over Duration Should Correct  ${DEFAULT_MAXCAP}  3  1
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention008 - MaxCap is disabled if the value is -1 in autoevent
    ${retention}  Create Dictionary  maxCap=${-1}  minCap=${5}  duration=1s
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  ${DEFAULT_MAXCAP}  1  168h
    And Set Test Variable  ${deviceName}  data-retention-device8
    When Create Events With AutoEvent Retention  100ms  ${retention}
    And Sleep  1s
    Then Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    And Retention For sourceName ${TEST_COMMAND_2} Should Be Skipped
    And Stored Event Count Over Duration Should Correct  -1  5  1
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention009 - MinCap is disabled if the value is -1 in autoevent
    ${retention}  Create Dictionary  maxCap=${8}  minCap=${-1}  duration=1s
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  ${DEFAULT_MAXCAP}  1  168h
    And Set Test Variable  ${deviceName}  data-retention-device9
    When Create Events With AutoEvent Retention  100ms  ${retention}
    And Sleep  1s
    Then Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    And Retention For sourceName ${TEST_COMMAND_2} Should Be Skipped
    And Stored Event Count Over Duration Should Correct  8  -1  1
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention010 - No MinCap is set in the auto-event
    ${retention}  Create Dictionary  maxCap=${8}  duration=1s
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  ${DEFAULT_MAXCAP}  ${DEFAULT_MINCAP}  168h
    And Set Test Variable  ${deviceName}  data-retention-device10
    When Create Events With AutoEvent Retention  100ms  ${retention}
    And Sleep  1s
    Then Wait Until Keyword Succeeds  3x  1s  Purge Log Found in core-data
    And Retention For sourceName ${TEST_COMMAND_2} Should Be Skipped
    And Stored Event Count Over Duration Should Correct  8  ${DEFAULT_MINCAP}  1
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

CoreDataRetention011 - All events with the source should be purged when set MinCap=-1 and duration=0s in the autoevent
    ${retention}  Create Dictionary  maxCap=${8}  minCap=${-1}  duration=0s
    Given Set Core-Data Retention In Registry Service  ${DEFAULT_INTERVAL}  ${DEFAULT_MAXCAP}  1  168h
    And Set Test Variable  ${deviceName}  data-retention-device11
    When Create Events With AutoEvent Retention  100ms  ${retention}
    And Sleep  3s
    Then No Purge Log Found in core-data
    And Retention For sourceName ${TEST_COMMAND_2} Should Be Skipped
    And Stored Event Count Over Duration Should Correct  10  -1  0
    [Teardown]  Run Keywords  Dump Last 100 lines Log  core-data
                ...      AND  Run Keyword And Ignore Error  Delete Device By Name ${deviceName}
                ...      AND  Delete all events by age

*** Keywords ***
Set Core-Data Retention In Registry Service
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

Get Purge Timestamp
    ${pattern}  Set Variable    .*purge events by duration.*?${TEST_COMMAND_1}.*
    ${purge_log}  Get Regexp Matches  ${service_log}  ${pattern}
    ${purge_log_line}  Get From List  ${purge_log}  -1
    ${purge_log_time}  Get Regexp Matches  ${purge_log_line}  \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.\\d+
    @{purge_log_time_list}  Split String  ${purge_log_time}[0]  .
    ${purge_second}  Convert Date  ${purge_log_time_list}[0]  result_format=epoch
    ${purge_second}  Convert To Integer  ${purge_second}
    ${purge_nano}  Convert To String  ${purge_log_time_list}[1]
    IF  len($purge_nano) < 9
        ${padded}    Evaluate    f"{$purge_nano:0<9}"
        ${purge_time}  Set Variable  ${purge_second}${padded}
    ELSE
        ${purge_time}  Set Variable  ${purge_second}${purge_nano}
    END
    RETURN  ${purge_time}

Stored Event Count Over Duration Should Correct
    [Arguments]  ${max}  ${min}  ${duration}
    IF  ${PURGE_EXECUTE} == 0
        ${purge_time}  Get Purge Timestamp
        ${compare_time}  Evaluate  int(${purge_time})-int(${duration})*1000000000
    ELSE
        ${time}  Get Current Nanoseconds Epoch Time
        ${compare_time}  Evaluate  ${time} - 3000000000
    END
    ${count}  Set Variable  ${0}
    Query events by device name  ${deviceName}
    FOR  ${INDEX}  IN RANGE  len(${content}[events])
        ${event}  Set Variable  ${content}[events][${INDEX}]
        IF  "${event}[sourceName]" == "${TEST_COMMAND_1}" and ${event}[origin] <= ${compare_time}
            ${count}  Evaluate  ${count} + 1
        END
    END
    IF  int(${max}) == -1
        Should Be True  ${min} <= ${count}
    ELSE IF  int(${min}) == -1
        Should Be True  ${count} <= ${max}
    ELSE
        Should Be True  ${min} <= ${count} <= ${max}
    END

Purge Log Found in ${service}
    Get Log in core-data
    ${pattern}  Set Variable   .*purge events by duration.*?${TEST_COMMAND_1}.*
    ${purge_log}  Get Regexp Matches  ${service_log}  ${pattern}
    Run Keyword If  len(${purge_log}) > 0  Log  Purge Log Was Found
    ...       ELSE  Fail  No Purge Log Was Found
    Delete Device By Name ${deviceName}
    Set Test Variable  ${PURGE_EXECUTE}  ${0}

No Purge Log Found in ${service}
    Get Log in core-data
    ${pattern}  Set Variable   .*purge events by duration.*?${TEST_COMMAND_1}.*
    ${purge_log}    Get Regexp Matches  ${service_log}  ${pattern}
    Run Keyword If  len(${purge_log}) == 0  Log  No Purge Log Was Found
    ...       ELSE  Fail  Purge Log Was Found
    Delete Device By Name ${deviceName}
    Set Test Variable  ${PURGE_EXECUTE}  ${1}

Get Log in ${service}
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service} ${timestamp}
             ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    Log  ${logs.stdout}
    Set Test Variable  ${service_log}  ${logs.stdout}

Create Events With AutoEvent Interval ${interval}
    Create AutoEvent Device  ${interval}  false  ${PREFIX}_GenerateDeviceValue_INT8_RW
    Sleep  1s
    Set To Dictionary    ${Device}[0][device][autoEvents][0]  interval=1s
    Update Devices ${Device}

    # Use in keyword "Get Log in ${service}"
    ${current_time}  Get current epoch time
    Set Test Variable  ${timestamp}  ${current_time}

Create Events With AutoEvent Retention
    [Arguments]  ${interval}  ${retention}
    ${device}  Generate Device With AutoEvent Data  ${interval}  false  ${TEST_COMMAND_1}
    Set To Dictionary  ${device}[autoEvents][0]  retention=${retention}
    ${autoEvent_int16}  Set autoEvents values  1s  false  ${TEST_COMMAND_2}
    Append To List  ${device}[autoEvents]  ${autoEvent_int16}
    Generate Devices  ${device}
    Create Device With ${Device}
    sleep  1500ms
    Set To Dictionary    ${Device}[0][device][autoEvents][0]  interval=1s
    Update Devices ${Device}

    # Use in keyword "Get Log in ${service}"
    ${current_time}  Get current epoch time
    Set Test Variable  ${timestamp}  ${current_time}

Retention For sourceName ${command} Should Be Skipped
    Get Log in core-data
    ${pattern}  Set Variable   .*Skip the event retention.*?${command}.*
    ${purge_log}  Get Regexp Matches  ${service_log}  ${pattern}
    Run Keyword If  len(${purge_log}) > 0  Log  Skipped Purge Log For '${command}' Was Found
    ...       ELSE  Fail  No Skipped Purge Log For '${command}' Was Found
