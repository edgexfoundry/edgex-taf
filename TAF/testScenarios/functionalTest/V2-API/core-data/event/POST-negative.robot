*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Data Event POST Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-post-negative.log
${api_version}    v2

*** Test Cases ***
ErrEventPOST001 - Create events fails (Event ID Conflict)
    Given Generate Event Sample  Event  Device-Test-001  Profile-Test-001  Simple Reading  Simple Float Reading
    And Create Event With Device-Test-001 And Profile-Test-001
    When Create Event With Id Conflict
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrEventPOST002 - Create events fails (Bad Events)
    ${bad_property}=  Create List  no_deviceName  no_profileName  no_origin  no_readings  no_id  bad_id
    FOR  ${property}  IN  @{bad_property}
         Given Generate Bad Event With ${property}
         And Create Event With Device-Test-002 And Profile-Test-002
         Then Should Return Status Code "400"
         And Should Return Content-Type "application/json"
         And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    END

ErrEventPOST003 - Create events fails (Bad Simple Readings)
    ${bad_property}=  Create List  no_deviceName  no_resourceName  no_profileName  no_origin  no_valueType  bad_valueType  no_value
    FOR  ${property}  IN  @{bad_property}
         Given Generate Bad Simple Reading With ${property}
         And Create Event With Device-Test-002 And Profile-Test-002
         Then Should Return Status Code "400"
         And Should Return Content-Type "application/json"
         And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    END

ErrEventPOST004 - Create events fails (Bad Binary Readings)
    ${bad_property}=  Create List  no_binaryValue  no_mediaType  no_valueType
    FOR  ${property}  IN  @{bad_property}
         Given Generate Bad Binary Reading With ${property}
         And Create Event With Device-Test-002 And Profile-Test-002
         Then Should Return Status Code "400"
         And Should Return Content-Type "application/json"
         And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    END

*** Keywords ***
Create Event With Id Conflict
    ${exist_id}=  Set Variable  ${id}
    Generate Event Sample  Event With Tags  Device-Test-001  Profile-Test-001  Simple Reading
    Set to dictionary  ${event}[event]  id=${exist_id}
    Create Event With Device-Test-001 And Profile-Test-001

Generate Bad Event With ${property}
    Generate Event Sample  Event  Device-Test-002  Profile-Test-002  Simple Reading
    ${no_property}=  Fetch From Right  ${property}  no_
    Run keyword if  "${property}" == "bad_id"  Set to dictionary  ${event}[event]  id=Invalid_ID
    ...    ELSE IF  "${property}" == "no_origin"  Set to dictionary  ${event}[event]  origin=${0}
    ...    ELSE IF  "${property}" == "no_readings"  Set to dictionary  ${event}[event]  readings=@{EMPTY}
    ...    ELSE     Set to dictionary  ${event}[event]  ${no_property}=${EMPTY}

Generate Bad Simple Reading With ${property}
    Generate Event Sample  Event  Device-Test-002  Profile-Test-002  Simple Reading  Simple Reading
    ${no_property}=  Fetch From Right  ${property}  no_
    Run keyword if  "${property}" == "bad_valueType"  Set to dictionary  ${event}[event][readings][0]  valueType=Invalid_type
    ...    ELSE IF  "${property}" == "no_origin"  Set to dictionary  ${event}[event][readings][0]  origin=${0}
    ...    ELSE     Set to dictionary  ${event}[event][readings][0]  ${no_property}=${EMPTY}

Generate Bad Binary Reading With ${property}
    Generate Event Sample  Event  Device-Test-002  Profile-Test-002  Binary Reading
    ${no_property}=  Fetch From Right  ${property}  no_
    Set to dictionary  ${event}[event][readings][0]  ${no_property}=${EMPTY}
