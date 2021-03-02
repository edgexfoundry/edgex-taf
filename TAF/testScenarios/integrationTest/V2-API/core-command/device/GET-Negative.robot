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
${SUITE}          Core-Command GET Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-get-negative.log
${api_version}    v2

*** Test Cases ***
ErrCommandGET001 - Query all DeviceCoreCommands with non-int value on offset
    When Query All DeviceCoreCommands With Invalid Offset
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET002 - Query all DeviceCoreCommands with invalid offset range
    When Query All DeviceCoreCommands With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET003 - Query all DeviceCoreCommands with non-int value on limit
    When Query All DeviceCoreCommands With Invalid Limit
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET004 - Query DeviceCoreCommand with non-existent device name
    When Query DeviceCoreCommand With Non-existent Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET005 - Get non-existent device read command
    When Get Specified Device Read Command With Non-existent Device Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET006 - Get specified device non-existent read command
    When Get Specified Device Read Command With Non-existent Command Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET007 - Get specified device read command with invalid ds-returnevent
    When Get Specified Device Read Command With Invalid ds-returnevent
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET008 - Get specified device read command with invalid ds-pushevent
    When Get Specified Device Read Command With Invalid ds-pushevent
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET009 - Get specified device read command when device AdminState is locked
    When Get Specified Device Read Command With AdminState Locked
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandGET010 - Get specified device read command when device OperatingState is down
    When Get Specified Device Read Command With OperatingState Down
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
