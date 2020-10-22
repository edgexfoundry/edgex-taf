*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device Service GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceservice-get-positive.log
${api_version}    v2

*** Test Cases ***
ServiceGET001 - Query all device services
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    When Query All Device Services
    Then Should Return Status Code "200" And services
    And Should Be True  len(${content}[services]) == 3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ServiceGET002 - Query all device services by offset
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    When Query All Device Services With offset=2
    Then Should Return Status Code "200" And services
    And Should Be True  len(${content}[services]) == 1
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ServiceGET003 - Query all device services by limit
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    When Query All Device Services With limit=2
    Then Should Return Status Code "200" And services
    And Should Be True  len(${content}[services]) == 2
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ServiceGET004 - Query all device services by labels
    Given Generate Multiple Device Services Sample
    And Set To Dictionary  ${deviceService}[2][service]  labels=@{EMPTY}
    And Append To List  ${deviceService}[1][service][labels]  new_label
    And Create Device Service ${deviceService}
    When Query All Device Services With labels=device-example
    Then Should Return Status Code "200" And services
    And Should Be True  len(${content}[services]) == 2
    And Should Return Content-Type "application/json"
    And Device Services Should Be Linked To Specified Label: device-example
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ServiceGET005 - Query device service by name
    Given Generate An Device Service Sample
    And Create Device Service ${deviceService}
    When Query Device Service By Name  Test-Device-Service
    Then Should Return Status Code "200" And service
    And Should Be True  "${content}[service][name]" == "Test-Device-Service"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Service By Name  Test-Device-Service

*** Keywords ***
Device Services Should Be Linked To Specified Label: ${label}
    ${services}=  Set Variable  ${content}[services]
    FOR  ${item}  IN  @{services}
        List Should Contain Value  ${item}[labels]  ${label}
    END
