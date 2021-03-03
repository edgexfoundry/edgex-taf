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
${SUITE}          Core-Command GET Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-get-positive.log
${api_version}    v2

*** Test Cases ***
CommandGET001 - Query all DeviceCoreCommands
    When Query All DeviceCoreCommands
    Then Should Return Status Code "200" And deviceCoreCommands
    And DeviceCoreCommands Count Should Be Correct
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET002 - Query all DeviceCoreCommands by offset
    When Query All DeviceCoreCommands By Offset
    Then Should Return Status Code "200" And deviceCoreCommands
    And DeviceCoreCommands Count Should Be Correct
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET003 - Query all DeviceCoreCommands by limit
    When Query All DeviceCoreCommands By Limit
    Then Should Return Status Code "200" And deviceCoreCommands
    And DeviceCoreCommands Count Should Be Correct
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET004 - Query DeviceCoreCommand by device name
    When Query DeviceCoreCommands By Name
    Then Should Return Status Code "200" And deviceCoreCommand
    And DeviceCoreCommands Count Should Be Correct
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET005 - Get specified device read command
    When Get Specified Device Read Command
    Then Should Return Status Code "200" And event
    And deviceName Should Match
    And resourceName Should Match
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET006 - Get specified device read command when ds-returnevent is no
    When Get Specified Device Read Command With ds-returnevent No
    Then Should Return Status Code "200"
    And Event Should Be Empty
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET007 - Get specified device read command when ds-pushevent is yes
    When Get Specified Device Read Command With ds-pushevent Yes
    Then Should Return Status Code "200" And event
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Has Been Pushed To Core Data
