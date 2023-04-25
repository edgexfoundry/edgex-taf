*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Profile PATCH Basicinfo Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-basicinfo-negative.log

*** Test Cases ***
ErrProfileBasicInfoPATCH001 - Update basicinfo with Empty profile name
    # Empty profile name
    Given Generate a basicinfo sample for updating
    And Set To Dictionary  ${basicinfoProfile}[0][basicinfo]  name=${EMPTY}
    When Update basicinfo ${basicinfoProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileBasicInfoPATCH002 - Update basicinfo with Non-existent profile name
    # Non-existent profile name
    Given Generate a basicinfo sample for updating
    And Set To Dictionary  ${basicinfoProfile}[0][basicinfo]  name=Non-existent
    When Update basicinfo ${basicinfoProfile}
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}
