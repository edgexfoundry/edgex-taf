*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device PATCH Device Command Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-devicecommand-negative.log

*** Test Cases ***
ErrProfileCommandPATCH001 - Update deviceCommand with device profile name validation error
    # non-existent device profile name
    When Update deviceCommand with Non-existent device profile name
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileCommandPATCH002 - Update deviceCommand with deviceCommand name validation error
    # deviceCommands > deviceCommand with non-existent command name
    # Contains valid profile body
    Given Generate a profile and command sample for updating
    And Set To Dictionary  ${commandUpdate}[0][devicecommand]  name=non-existent
    When Update command ${commandUpdate}
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${test_profile}

ErrProfileCommandPATCH003 - Update deviceCommand with deviceCommand isHidden validation error
    # deviceCommands > deviceCommand invalid isHidden
    # Contains valid profile body
    Given Generate a profile and command sample for updating
    And Set To Dictionary  ${commandUpdate}[0][devicecommand]  isHidden=${EMPTY}
    When Update command ${commandUpdate}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${test_profile}

*** Keywords ***
Update deviceCommand with Non-existent device profile name
    ${command}=  Create Dictionary  name=CurrentStatus  isHidden=${false}
    Generate updating command  ${command}
    Set to Dictionary  ${commandUpdate}[0]  profileName=non-existent
    Update command ${commandUpdate}
