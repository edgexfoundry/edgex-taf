*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Service PATCH Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceservice-patch-positive.log

*** Test Cases ***
DevicePATCH001 - Update device services
    # operatingState, adminState, labels, baseAddress
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    When Update Device Service ${deviceService}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Service Data Should Be Updated
    [Teardown]  Delete Multiple Device Services By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

*** Keywords ***
Service Data Should Be Updated
    ${list}=  Create List  Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ${expected_keys}=  Create List  name  adminState  baseAddress
    FOR  ${service}  IN  @{list}
        Query Device Service By Name  ${service}
        ${keys}=  Get Dictionary Keys  ${content}[service]
        List Should Contain Sub List  ${keys}  ${expected_keys}
        Run Keyword If  "${service}" == "Device-Service-${index}-1"
        ...             List Should Contain Value  ${content}[service][labels]  device-update
        ...    ELSE IF  "${service}" == "Device-Service-${index}-2"
        ...             Should Be Equal  ${content}[service][adminState]  LOCKED
        ...    ELSE IF  "${service}" == "Device-Service-${index}-3"
        ...             Should Be Equal  ${content}[service][baseAddress]  http://home-device-service:59901
    END

