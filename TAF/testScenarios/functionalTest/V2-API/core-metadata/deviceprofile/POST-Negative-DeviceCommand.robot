*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Device Command Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-post-devicecommand-negative.log

*** Test Cases ***
ErrProfileCommandPOST001 - Add deviceCommand with Empty profile name
    # Empty profile name
    When Add New Command With Empty profile name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileCommandPOST002 - Add deviceCommand with Non-existent profile name
    # Non-existent profile name
    When Add New Command With Non-existent profile name
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileCommandPOST003 - Add deviceCommand with Duplicate command name
    # 2 device command with same command name
    Given Create A Device Profile Sample
    When Add New Command With the Same Command Name
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileCommandPOST004 - Add deviceCommand with Empty Command name
    # deviceCommands > deviceCommand without name
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Command With Empty Command Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileCommandPOST005- Add deviceCommand with Empty readWrite
    # deviceCommands > deviceCommand without readWrite
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Command With Empty readWrite
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileCommandPOST006- Add deviceCommand with Invalid readWrite
    # deviceCommands > deviceCommand invalid readWrite
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Command With Invalid readWrite
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileCommandPOST007 - Add deviceCommand with Empty deviceResource
    # deviceCommand > resourceOperations without deviceResource
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Command With Empty deviceResource
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileCommandPOST008 - Add deviceCommand with Non-existent deviceResource
    # deviceCommand > resourceOperations Non-existent deviceResource
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Command With Non-existent deviceResource
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name
