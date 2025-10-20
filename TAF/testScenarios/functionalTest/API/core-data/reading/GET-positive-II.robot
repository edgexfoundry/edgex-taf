*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Delete all events by age
Suite Teardown  Run Teardown Keywords

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
    And totalCount Should be 3
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
    And totalCount Should be 3
    And Total 3 Readings Should Be Created Between ${start_time} And ${end_time}
    And All 3 Readings Should Contain deviceName ${device_name} And resourceName ${resource_name}
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET012 - Query all readings with offset=-1
    Given Create Multiple Events
    When Query All Readings With offset=-1
    Then Should Return Status Code "200"
    And totalCount Should be 0
    And Should Be True  len(${content}[readings]) == 9
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete All Events By Age

ReadingGET013 - Query all readings with numeric=true
    Given Create Multiple Events With numeric and non-numeric
    When Query All Readings With numeric=true
    Then Should Return Status Code "200"
    And totalCount Should be 11
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Numeric ValueType Should Have Numeric Value
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

Create Multiple Events With numeric and non-numeric
    Create Multiple Events
    Generate event sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  String Reading
    Create Event With Service-Test-001 and Profile-Test-001 and Device-Test-001 and Command-Test-001
    Generate event sample  Event  Device-Test-001  Profile-Test-001  Command-Test-001  Bool Reading
    Create Event With Service-Test-001 and Profile-Test-001 and Device-Test-001 and Command-Test-001

Numeric ValueType Should Have Numeric Value
    FOR    ${reading}    IN    @{content}[readings]
        ${actual_type}=    Evaluate    type($reading['value']).__name__
        IF    '${reading}[valueType]' == 'Bool' or '${reading}[valueType]' == 'String'
            Should Be True    '${actual_type}'  'str'
        ELSE
            Should Be True    '${actual_type}'  'int'
        END
    END
