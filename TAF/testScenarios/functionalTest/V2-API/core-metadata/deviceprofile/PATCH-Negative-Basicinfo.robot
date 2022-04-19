*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile PATCH Basicinfo Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-basicinfo-negative.log

*** Test Cases ***
ErrProfileBasicInfoPATCH001 - Update basicinfo with name validation error
    #Empty profile name
    Given Generate A Device Profile Sample for basicinfo
    And Set To Dictionary  ${deviceProfile}[0][profile]  name=${EMPTY}
    When Update Basicinfo ${deviceProfile}
    Then Should Return Status Code "400"
    [Teardown]  Delete Device Profile By Name

ErrProfileBasicInfoPATCH002 - Update basicinfo with invalid profile name
    #Non-existent profile name
    Given Generate A Device Profile Sample for basicinfo  Test-Profile-5
    And Set To Dictionary  ${deviceProfile}[0][profile]  name=Non-existent
    When Update Basicinfo ${deviceProfile}
    And Should Return Status Code "404"
    [Teardown]  Delete Device Profile By Name

