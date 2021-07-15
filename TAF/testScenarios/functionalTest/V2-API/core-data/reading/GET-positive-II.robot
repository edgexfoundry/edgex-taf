*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Delete all events by age
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Reading GET Postive II Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-get-reading-positive-II.log

*** Test Cases ***
ReadingGET010 - Query readings by device name and resource name
    ${device_name}  Set Variable  Device-Test-002
    ${resource_name}  Set Variable  Simple-Reading
    Given Create Multiple Events
    When Query Readings By deviceName And resourceName  ${device_name}  ${resource_name}
    Then Should Return Status Code "200"
    And Should Be True  len(${content}[readings]) == 3
    And All 3 Readings Should Contain deviceName ${device_name} And resourceName ${resource_name}
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET011 - Query readings by device name and resource name between start/end time
    ${device_name}  Set Variable  Device-Test-002
    ${resource_name}  Set Variable  Simple-Reading
    Given Create Multiple Events Twice To Get Start/End Time
    When Query readings by device and resource between start/end time
    ...   ${device_name}  ${resource_name}  ${start_time}  ${end_time}
    Then Should Return Status Code "200"
    And Total 3 Readings Should Be Created Between ${start_time} And ${end_time}
    And All 3 Readings Should Contain deviceName ${device_name} And resourceName ${resource_name}
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age


*** Keywords ***
All ${number} Readings Should Contain deviceName ${device_name} And resourceName ${resource_name}
    ${count}=  Get Length  ${content}[readings]
    Should Be Equal As Integers  ${count}  ${number}
    FOR  ${index}  IN RANGE  0  ${number}
        Should Be Equal As Strings  ${device_name}  ${content}[readings][${index}][deviceName]
        Should Be Equal As Strings  ${resource_name}  ${content}[readings][${index}][resourceName]
    END

Total ${number} Readings Should Be Created Between ${start} And ${end}
    ${count}=  Get Length  ${content}[readings]
    Should Be Equal As Integers  ${count}  ${number}
    FOR  ${index}  IN RANGE  0  ${number}
        Should Be True  ${end} >= ${content}[readings][${index}][origin] >=${start}
    END
