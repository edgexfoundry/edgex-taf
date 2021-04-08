*** Settings ***
Library         TAF/testCaseModules/keywords/setup/edgex.py
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource        TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Suite Setup     Run Keywords  Setup Suite
...                           AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                           AND  Deploy Device Service  device-virtual  service_default
Suite Teardown  Run keywords  Remove Services  device-virtual
...                           AND  Delete Device Virtual Pre-define Devices
...                           AND  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core-Command GET Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-command-get-positive.log

*** Test Cases ***
CommandGET001 - Query all DeviceCoreCommands
    When Query All DeviceCoreCommands
    Then Should Return Status Code "200" And deviceCoreCommands
    And Should Be True  len(${content}[deviceCoreCommands]) == 5
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET002 - Query all DeviceCoreCommands by offset
    When Query All DeviceCoreCommands With offset=2
    Then Should Return Status Code "200" And deviceCoreCommands
    And Should Be True  len(${content}[deviceCoreCommands]) == 3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET003 - Query all DeviceCoreCommands by limit
    When Query All DeviceCoreCommands With limit=3
    Then Should Return Status Code "200" And deviceCoreCommands
    And Should Be True  len(${content}[deviceCoreCommands]) == 3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET004 - Query DeviceCoreCommand by device name
    When Query DeviceCoreCommands By Device Name  Random-Integer-Device
    Then Should Return Status Code "200" And deviceCoreCommand
    And Should Be True  "${content}[deviceCoreCommand][deviceName]" == "Random-Integer-Device"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET005 - Get specified device read command
    When Get Specified Device Random-Binary-Device Read Command Binary
    Then Should Return Status Code "200" And event
    And Should Be True  "${content}[event][deviceName]" == "Random-Binary-Device"
    And Should Be True  "${content}[event][sourceName]" == "Binary"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET006 - Get specified device read command when ds-returnevent is no
    When Get Device Random-Boolean-Device Read Command Bool With ds-returnevent=no
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

CommandGET007 - Get specified device read command when ds-pushevent is yes
    When Get Device Random-Float-Device Read Command Float32 With ds-pushevent=yes
    Then Should Return Status Code "200" And event
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Has Been Pushed To Core Data

*** Keywords ***
Event Has Been Pushed To Core Data
    ${id}=  Set Variable  ${content}[event][id]
    Create Session  Core Data  url=${coreDataUrl}  disable_warnings=true
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    ${resp}=  GET On Session  Core Data  ${coreDataEventUri}/id/${id}  headers=${headers}
    ...       expected_status=200
    Set Response to Test Variables  ${resp}
    Should Be True  "${content}[event][deviceName]" == "Random-Float-Device"
