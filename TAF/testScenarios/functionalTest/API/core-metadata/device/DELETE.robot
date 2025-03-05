*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device DELETE Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-delete.log

*** Test Cases ***
DeviceDELETE001 - Delete device by name
    Given Create A Device Sample With Associated device-virtual And Test-Profile-2
    When Delete Device By Name Test-Device
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Should Be Deleted
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

ErrDeviceDELETE001 - Delete device by name with non-existent name
    When Delete Device By Name Non-Existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrDeviceDELETE002 - Delete device when it has children
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  parent=${Device}[0][device][name]
    And Set To Dictionary  ${Device}[2][device]  parent=${Device}[1][device][name]
    And Create Device With ${Device}
    When Delete Device By Name ${Device}[1][device][name]
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names  ${Device}[2][device][name]  ${Device}[1][device][name]
                ...           ${Device}[0][device][name]  ${Device}[3][device][name]
                ...      AND  Delete multiple device profiles by names  Test-Profile-1  Test-Profile-2  Test-Profile-3

*** Keywords ***
Device Should Be Deleted
    Check existence of device by name   Test-Device
    Should Return Status Code "404"
