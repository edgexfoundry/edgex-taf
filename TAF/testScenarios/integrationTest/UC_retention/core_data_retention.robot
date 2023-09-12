*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run keywords  Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
             ...      AND  Enable Core-Data Retention
Suite Teardown  Run Keywords  Disable Core-Data Retention
                ...      AND  Run Teardown Keywords
Force Tags      MessageBus=redis

*** Variables ***
${SUITE}          core-data Retention
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_data_retention.log
${DATA_CONSOL_PATH}  ${CONSUL_CONFIG_BASE_ENDPOINT}/core-data
${maxCap}  5
${minCap}  2
${interval}  2s

*** Test Cases ***
CoreDataRetention001 - core-data retention is executed if reading count is over MaxCap value
    When Create 3 Events
    And Sleep  ${interval}
    Then Stored Event Count Should Be Equal 1
    And Stored Reading Count Should Be Equal 2
    [Teardown]  Delete all events by age

CoreDataRetention002 - core-data retention is not executed if reading count is less than MaxCap value
    When Create 2 Events
    And Sleep  ${interval}
    Then Stored Event Count Should Be Equal 2
    And Stored Reading Count Should Be Equal 4
    [Teardown]  Delete all events by age

*** Keywords ***
Enable Core-Data Retention
    ${keys}  Create List  Enabled  Interval  MaxCap  MinCap
    ${values}  Create List  true  3s  ${maxCap}  ${minCap}
    FOR  ${key}  ${value}  IN ZIP  ${keys}  ${values}
        ${path}=  Set Variable  ${DATA_CONSOL_PATH}/Retention/${key}
        Update Service Configuration On Consul  ${path}  ${value}
    END
    Restart Services  core-data

Create ${number} Events
  FOR  ${index}  IN RANGE  0  ${number}   # Create 1 event and 2 readings every time
    Generate Event Sample  Event  Device-Test-002  Profile-Test-001  Command-Test-002  Simple Reading  Simple Float Reading
    Create Event With Service-Test-001 and Profile-Test-001 and Device-Test-002 and Command-Test-002
  END

Stored ${object} Count Should Be Equal ${number}
    Run Keyword If  "${object}" == "Event"  Query all events count
    ...    ELSE IF  "${object}" == "Reading"  Query all readings count
    ...       ELSE  Fail  Valid Object: Event, Reading
    Should Be Equal As Integers  ${content}[Count]  ${number}

Disable Core-Data Retention
    ${path}=  Set Variable  ${DATA_CONSOL_PATH}/Retention/Enabled
    Update Service Configuration On Consul  ${path}  false
    Restart Services  core-data
