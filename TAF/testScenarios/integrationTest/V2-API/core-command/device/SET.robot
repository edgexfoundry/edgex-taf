*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Suite Setup     Run Keywords  Setup Suite
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                           AND  Deploy device service  device-virtual
Suite Teardown  Run keywords  Remove services  device-virtual
...                           AND  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core-Command Set Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-set.log
${api_version}    v2

*** Test Cases ***
CommandSET001 - Set specified device write command
    When Set Specified Device Write Command
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Vaules Have Been Updated

ErrCommandSET001 - Set specified device write command with non-existent device
    When Set Specified Device Write Command With Non-existent Device Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandSET002 - Set specified device write command with non-existent command
    When Set Specified Device Write Command With Non-existent Command Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandSET003 - Set specified device write command when device is locked
    When Set Specified Device Write Command With AdminState Locked
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
