*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core-Data Event POST Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-data-post-negative.log
${api_version}    v2

*** Test Cases ***
ErrEventPOST001 - Create events fails (Event ID Conflict)
    Given Generate Multiple Events Sample With Id Conflict
    When Create Events
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0,1,2 Should Contain Status Code "201" And id
    And Item Index 3 Should Contain Status Code "409" And no id

ErrEventPOST002 - Create events fails (Bad Events)
    ${bad_property}=  Create List  no_event  no_deviceName  no_origin  no_readings  no_id  bad_id
    FOR  ${property}  IN  @{bad_property}
         Given Generate Bad Event With ${property}
         And Create Events
         Then Should Return Status Code "400"
    END

ErrEventPOST003 - Create events fails (Bad Simple Readings)
    ${bad_property}=  Create List  no_deviceName  no_name  no_origin  no_valueType  bad_valueType  no_value  no_FloatEncoding
    FOR  ${property}  IN  @{bad_property}
         Given Generate Bad Simple Reading With ${property}
         And Create Events
         Then Should Return Status Code "400"
    END

ErrEventPOST004 - Create events fails (Bad Binary Readings)
    ${bad_property}=  Create List  no_binaryValue  no_mediaType  no_valueType
    FOR  ${property}  IN  @{bad_property}
         Given Generate Bad Binary Reading With ${property}
         And Create Events
         Then Should Return Status Code "400"
    END

*** Keywords ***
Generate Multiple Events Sample With Id Conflict
    Generate multiple events sample with simple readings
    ${existing_id}=  Set variable  ${id}
    Set to dictionary  ${events}[0][event]  id=${existing_id}

Generate Bad Event With ${property}
    Generate an event sample with simple readings
    ${no_property}=  Fetch From Right  ${property}  no_
    Run keyword if  "${property}" == "no_event"  Set to dictionary  ${events}[0]  event=
    ...    ELSE IF  "${property}" == "bad_id"  Set to dictionary  ${events}[0][event]  id=Invalid_ID
    ...    ELSE  Set to dictionary  ${events}[0][event]  ${no_property}=

Generate Bad Simple Reading With ${property}
    Generate an event sample with simple readings
    ${no_property}=  Fetch From Right  ${property}  no_
    Run keyword if  "${property}" == "bad_valueType"  Set to dictionary  ${events}[0][event][readings][0]  valueType=Invalid_type
    ...    ELSE IF  "${property}" == "no_FloatEncoding"  Set to dictionary  ${events}[0][event][readings][1]  floatEncoding=
    ...    ELSE  Set to dictionary  ${events}[0][event][readings][0]  ${no_property}=

Generate Bad Binary Reading With ${property}
    ${event}=  Generate event sample  Event  Device-Test-001  Binary Reading
    ${events}=  Create List  ${event}
    Set test variable  ${events}  ${events}
    ${no_property}=  Fetch From Right  ${property}  no_
    Set to dictionary  ${events}[0][event][readings][0]  ${no_property}=
