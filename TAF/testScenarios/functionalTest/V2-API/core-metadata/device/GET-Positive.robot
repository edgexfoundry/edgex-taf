*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-get-positive.log
${api_version}    v2

*** Test Cases ***
DeviceGET001 - Query all devices
    [Tags]  SmokeTest
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Create Device With ${Device}
    When Query All Devices
    Then Should Return Status Code "200" And devices
    And Should Be True  len(${content}[devices]) == 4
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

DeviceGET002 - Query all devices with offset
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Create Device With ${Device}
    When Query All Devices With offset=2
    Then Should Return Status Code "200" And devices
    And Should Be True  len(${content}[devices]) == 2
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

DeviceGET003 - Query all devices with limit
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Create Device With ${Device}
    When Query All Devices With limit=3
    Then Should Return Status Code "200" And devices
    And Should Be True  len(${content}[devices]) == 3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

DeviceGET004 - Query all devices with specified labels
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  labels=@{EMPTY}
    And Append To List  ${Device}[2][device][labels]  new_label
    And Create Device With ${Device}
    When Query All Devices With labels=device-example
    Then Should Return Status Code "200" And devices
    And Should Be True  len(${content}[devices]) == 3
    And Devices Should Be Linked To Specified Label: device-example
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

DeviceGET005 - Query device by name
    Given Create A Device Sample With Associated Test-Device-Service And Test-Profile-1
    When Query Device By Name  Test-Device
    Then Should Return Status Code "200" and device
    And Should Be True  "${content}[device][name]" == "Test-Device"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

DeviceGET006 - Check device exists by name
    Given Create A Device Sample With Associated Test-Device-Service And Test-Profile-2
    When Check Existence Of Device By Name  Test-Device
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

*** Keywords ***
Devices Should Be Linked To Specified Label: ${label}
    ${devices}=  Set Variable  ${content}[devices]
    FOR  ${item}  IN  @{devices}
        List Should Contain Value  ${item}[labels]  ${label}
    END
