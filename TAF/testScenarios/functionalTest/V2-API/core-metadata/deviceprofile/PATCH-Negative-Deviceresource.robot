*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile PATCH Deviceresource Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-deviceresource-negative.log

*** Test Cases ***
ErrProfileResourcePATCH001 - Update deviceResource with Non-existent profile name
    # non-existent device profile name
    When Update deviceResource With Non-existent device profile name
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileResourcePATCH002 - Update deviceResource with resource name validation error
    # deviceResources > deviceResource with non-existent resource name
    # Contains valid profile body
    Given Create A Device Profile with deviceResource
    When Update deviceResource With non-existent resource name
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileResourcePATCH003 - Update deviceResource with isHidden validation error
    # deviceResources > deviceResource invalid isHidden
    # Contains valid profile body
    Given Create A Device Profile with deviceResource
    When Update deviceResource With invalid isHidden
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name
