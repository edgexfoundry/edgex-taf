*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-post-negative-ll.log
${api_version}    v2

*** Test Cases ***
ErrDevicePOST010 - Create device with non-existent device service name
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-1
    And Set To Dictionary  ${Device}[1][device]  serviceName=Non-existent
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index 0,2,3 Should Contain Status Code "201" And id
    And Item Index 1 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names
    ...                       Test-Device  Test-Device-Disabled  Test-Device-AutoEvents
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

ErrDevicePOST011 - Create device with non-existent device profile name
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-2
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-2
    And Set To Dictionary  ${Device}[2][device]  profileName=Non-existent
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index 0,1,3 Should Contain Status Code "201" And id
    And Item Index 2 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names
    ...                       Test-Device  Test-Device-Locked  Test-Device-AutoEvents
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2
