*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Suite Setup     Run Keywords  Setup Suite
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                           AND  Deploy Device Service  device-virtual  service_default
Suite Teardown  Run keywords  Remove Services  device-virtual
...                           AND  Delete Device Virtual Pre-define Devices
...                           AND  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Command Set Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-set.log

*** Test Cases ***
CommandSET001 - Set specified device write command
    ${set_data}=  Create Dictionary  Int8=32
    When Set Specified Device Random-Integer-Device Write Command WriteInt8Value With ${set_data}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Vaules Have Been Updated

ErrCommandSET001 - Set specified device write command with non-existent device
    ${set_data}=  Create Dictionary  Bool=true
    When Set Specified Device Non-existent-Device Write Command WriteBoolValue With ${set_data}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandSET002 - Set specified device write command with non-existent command
    When Set Specified Device Random-Binary-Device Write Command WriteBinary With &{EMPTY}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrCommandSET003 - Set specified device write command when device is locked
    ${set_data}=  Create Dictionary  Float32=99.2
    Given Update Device Random-Float-Device With adminState=LOCKED
    When Set Specified Device Random-Float-Device Write Command WriteFloat32Value With ${set_data}
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Update Device Random-Float-Device With adminState=UNLOCKED


*** Keywords ***
Vaules Have Been Updated
  Get Specified Device Random-Integer-Device Read Command Int8
  Should Be True  "${content}[event][readings][0][value]" == "32"
