*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run keywords  Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
             ...      AND  Delete all events by age
Suite Teardown  Run Keywords  Delete all events by age
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}          autoEvent onChangeThreshold
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_data_retention.log
${DATA_CONSOL_PATH}  /core-data
${resourceName}  ${PREFIX}_DeviceValue_INT8_RW
${threshold}  ${100}

*** Test Cases ***
onChangeThreshold001 - Event is created only if the reading value exceeds the threshold
    Given Set Test Variable  ${deviceName}  onChangeThreshold001-test
    When Create AutoEvent Device  50ms  true  ${PREFIX}_GenerateDeviceValue_INT8_RW  ${threshold}
    Then Only Event Is Created If Reading Value Exceeds Threshold
    [Teardown]  Delete Device By Name ${deviceName}

*** Keywords ***
Only Event Is Created If Reading Value Exceeds Threshold
    Sleep  1s
    Query Readings By deviceName And resourceName  ${deviceName}  ${resourceName}
    Run Keyword If  len(${content}[readings]) == 0  Fail  No readings was found
    FOR  ${INDEX}  IN RANGE  len(${content}[readings])-1
        ${compare_index}  Evaluate   ${INDEX}+1
        ${calculate_value}  Evaluate  abs(${content}[readings][${INDEX}][value]-${content}[readings][${compare_index}][value])
        Should Be True  ${calculate_value} >= ${threshold}
    END
