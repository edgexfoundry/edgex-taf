*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Service POST Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceservice-post-negative.log
${api_version}    v2


*** Test Cases ***
ErrServicePOST001 - Create device service with duplicate service name
    # 2 device services with same service name
    [Tags]  Skipped
    Given Generate Multiple Device Services Sample
    And Set to Dictionary  ${deviceService}[1][service]  name=${deviceService}[0][service][name]
    When Create Device Service ${deviceService}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0,2 Should Contain Status Code "201" And id
    And Item Index 1 Should Contain Status Code "409" And no id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Services By Names  Device-Service-${index}-1  Device-Service-${index}-3

ErrServicePOSTValidate001 - Create device service with empty property
    # operatingState property will be removed soon
    ${bad_property}=  Create List  no_adminState  no_operatingState  no_name  no_baseAddress
    FOR  ${property}  IN  @{bad_property}
         Given Generate Multiple Device Services With ${property}
         When Create Device Service ${deviceService}
         Then Should Return Status Code "400"
         And Should Return Content-Type "application/json"
         And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    END

ErrServicePOSTValidate002 - Create device service with invalid property
    # operatingState property will be removed soon
    ${bad_property}=  Create List  bad_adminState  bad_operatingState
    FOR  ${property}  IN  @{bad_property}
         Given Generate Multiple Device Services With ${property}
         When Create Device Service ${deviceService}
         Then Should Return Status Code "400"
         And Should Return Content-Type "application/json"
         And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    END

*** Keywords ***
Generate Multiple Device Services With ${property}
    Generate Multiple Device Services Sample
    ${bad_property}=  Split String  ${property}  _
    Run Keyword If  "${bad_property}[0]" == "no"
    ...             Set to dictionary  ${deviceService}[1][service]  ${bad_property}[1]=${EMPTY}
    ...    ELSE IF  "${bad_property}[0]" == "bad"
    ...             Set to dictionary  ${deviceService}[1][service]  ${bad_property}[1]="InValid"
