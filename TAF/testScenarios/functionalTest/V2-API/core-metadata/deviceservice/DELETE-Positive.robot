*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Service DELETE Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceservice-delete-positive.log
${api_version}    v2

*** Test Cases ***
ServiceDELETE001 - Delete device service by name
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    When Delete Device Service By Name  Test-Device-Service
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Service Should Be Deleted  Test-Device-Service

*** Keywords ***
Device Service Should Be Deleted
    [Arguments]  ${device_service_name}
    Run Keyword And Expect Error  "*not found"  Query device service by name  ${device_service_name}
    Should Return Status Code "404"
