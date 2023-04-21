*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device PATCH Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-patch-negative-ll.log

*** Test Cases ***
ErrDevicePATCH0011 - Update device with non-existent serviceName
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[0][device]  serviceName=Non-existent
    When Update Devices ${Device}
    Then Should Return Status Code "207"
    And Item Index 1,2,3 Should Contain Status Code "200"
    And Item Index 0 Should Contain Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

ErrDevicePATCH012 - Update device with non-existent profileName
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[1][device]  profileName=Non-existent
    When Update Devices ${Device}
    And Item Index 0,2,3 Should Contain Status Code "200"
    And Item Index 1 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample
