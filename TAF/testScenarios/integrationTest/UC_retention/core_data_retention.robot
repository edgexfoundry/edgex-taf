*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run keywords  Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
             ...      AND  Delete all events by age
             ...      AND  Enable Core-Data Retention
             ...      AND  Update Configuration On Registry Service  ${DATA_CONSOL_PATH}/Writable/LogLevel  DEBUG
Suite Teardown  Run Keywords  Disable Core-Data Retention
                ...      AND  Update Configuration On Registry Service  ${DATA_CONSOL_PATH}/Writable/LogLevel  INFO
                ...      AND  Run Teardown Keywords
Force Tags      MessageBus=redis

*** Variables ***
${SUITE}          core-data Retention
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_data_retention.log
${DATA_CONSOL_PATH}  /core-data
${maxCap}  5
${minCap}  2
${interval}  2s

*** Test Cases ***
CoreDataRetention001 - core-data retention is executed if reading count is over MaxCap value
    When Create 3 Events
    And Sleep  ${interval}
    And Wait Until Keyword Succeeds  3x  2s  Found Purge Log in core-data
    Then Stored Event Count Should Be Equal 1
    And Stored Readings Are Belong To Stored Events
    [Teardown]  Delete all events by age

CoreDataRetention002 - core-data retention is not executed if reading count is less than MaxCap value
    When Create 2 Events
    And Sleep  ${interval}
    Then Stored Event Count Should Be Equal 2
    And Stored Readings Are Belong To Stored Events
    [Teardown]  Delete all events by age

*** Keywords ***
Enable Core-Data Retention
    ${keys}  Create List  Enabled  Interval  MaxCap  MinCap
    ${values}  Create List  true  3s  ${maxCap}  ${minCap}
    FOR  ${key}  ${value}  IN ZIP  ${keys}  ${values}
        ${path}=  Set Variable  ${DATA_CONSOL_PATH}/Retention/${key}
        Update Configuration On Registry Service  ${path}  ${value}
    END
    Restart Services  core-data

Create ${number} Events
  FOR  ${index}  IN RANGE  0  ${number}   # Create 1 event and 2 readings every time
    Generate Event Sample  Event  Device-Test-002  Profile-Test-001  Command-Test-002  Simple Reading  Simple Float Reading
    Create Event With Service-Test-001 and Profile-Test-001 and Device-Test-002 and Command-Test-002
  END

Stored Event Count Should Be Equal ${number}
    Query all events
    Should Be True  ${content}[totalCount] == ${number}

Get Readings Ids From Event API
    ${ids}  Create List
    FOR  ${EVENT_INDEX}  IN RANGE  len(${content}[events])
        FOR  ${READING_INDEX}  IN RANGE  len(${content}[events][${EVENT_INDEX}][readings])
            Append To List  ${ids}  ${content}[events][${EVENT_INDEX}][readings][${READING_INDEX}][id]
        END
    END
    RETURN  ${ids}

Stored Readings Are Belong To Stored Events
    ${event_reading_ids}  Get Readings Ids From Event API
    Query All Readings
    ${reading_ids}  Create List
    FOR  ${INDEX}  IN RANGE  len(${content}[readings])
        Append To List  ${reading_ids}  ${content}[readings][${INDEX}][id]
    END
    Remove Duplicates  ${reading_ids}
    Lists Should Be Equal  ${event_reading_ids}  ${reading_ids}  ignore_order=True

Disable Core-Data Retention
    ${path}=  Set Variable  ${DATA_CONSOL_PATH}/Retention/Enabled
    Update Configuration On Registry Service  ${path}  false
    Restart Services  core-data

Found Purge Log in ${service}
    ${current_time}  Get current epoch time
    ${timestamp}  Evaluate  ${current_time}-3
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service} ${timestamp}
             ...     shell=True  stderr=STDOUT  output_encoding=UTF-8  timeout=5s
    Should Contain  ${logs.stdout}  Purging the reading amount
