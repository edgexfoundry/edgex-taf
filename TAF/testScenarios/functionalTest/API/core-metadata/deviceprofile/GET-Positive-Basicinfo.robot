*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Profile GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-get-positive.log

*** Test Cases ***
ProfileBasicGET001 - Query all device profiles basic info
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles Basic Info
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceResources and deviceCommands Both Should Not Return
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileBasicGET002 - Query all device profiles basic info by offset
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Set Test Variable  ${offset}  2
    When Query All Device Profiles Basic Info With offset=${offset}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount-offset
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceResources and deviceCommands Both Should Not Return
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileBasicGET003 - Query all device profiles basic info by limit
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    And Set Test Variable  ${limit}  2
    When Query All Device Profiles Basic Info With limit=${limit}
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match limit
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceResources and deviceCommands Both Should Not Return
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

ProfileBasicGET004 - Query all device profiles basic info by labels
    Given Generate Multiple Device Profiles Sample
    And Create Device Profile ${deviceProfile}
    When Query All Device Profiles Basic Info With labels=bacnet
    Then Should Return Status Code "200" And profiles
    And totalCount Is Greater Than Zero And ${content}[profiles] Count Should Match totalCount
    And Profiles Should Be Linked To Specified Labels: bacnet
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And deviceResources and deviceCommands Both Should Not Return
    [Teardown]  Delete Multiple Device Profiles By Names  Test-Profile-1  Test-Profile-2  Test-Profile-3

*** Keywords ***
deviceResources and deviceCommands Both Should Not Return
    FOR  ${INDEX}  IN RANGE  len(${content}[profiles])
        Dictionary Should Not Contain Key  ${content}[profiles][${INDEX}]  deviceResources
        Dictionary Should Not Contain Key  ${content}[profiles][${INDEX}]  deviceCommands
    END
