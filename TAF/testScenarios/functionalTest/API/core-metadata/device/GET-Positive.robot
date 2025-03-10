*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-get-positive.log

*** Test Cases ***
DeviceGET001 - Query all devices
    [Tags]  SmokeTest
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Create Device With ${Device}
    When Query All Devices
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match totalCount
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET002 - Query all devices with offset
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Create Device With ${Device}
    And Set Test Variable  ${offset}  2
    When Query All Devices With Parameters  offset=${offset}
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match totalCount-offset
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET003 - Query all devices with limit
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Create Device With ${Device}
    And Set Test Variable  ${limit}  3
    When Query All Devices With Parameters  limit=${limit}
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match limit
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET004 - Query all devices with specified labels
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  labels=@{EMPTY}
    And Append To List  ${Device}[2][device][labels]  new_label
    And Create Device With ${Device}
    When Query All Devices With Parameters  labels=device-sample
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match totalCount
    And Devices Should Be Linked To Specified Label: device-sample
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET005 - Query all devices with descendantsOf
    # default maxLevels=0, all sub-devices should be returned
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  parent=${Device}[0][device][name]
    And Set To Dictionary  ${Device}[2][device]  parent=${Device}[0][device][name]
    And Set To Dictionary  ${Device}[3][device]  parent=${Device}[1][device][name]
    And Create Device With ${Device}
    When Query All Devices With Parameters  descendantsOf=${Device}[0][device][name]
    Then Should Return Status Code "200" And devices
    And Children of Device ${Device}[0][device][name] Should Be Returned
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names  ${Device}[3][device][name]  ${Device}[2][device][name]
                ...           ${Device}[1][device][name]  ${Device}[0][device][name]
                ...      AND  Delete multiple device profiles by names  Test-Profile-1  Test-Profile-2  Test-Profile-3

DeviceGET006 - Query all devices with descendantsOf and maxLevels=1
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  parent=${Device}[0][device][name]
    And Set To Dictionary  ${Device}[2][device]  parent=${Device}[0][device][name]
    And Set To Dictionary  ${Device}[3][device]  parent=${Device}[1][device][name]
    And Create Device With ${Device}
    ${params}  Create Dictionary  descendantsOf=${Device}[0][device][name]   maxLevels=1
    When Query all devices with parameters  ${params}
    Then Should Return Status Code "200" And devices
    And Devices Should Be Children Of ${Device}[0][device][name]
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names  ${Device}[3][device][name]  ${Device}[2][device][name]
                ...           ${Device}[1][device][name]  ${Device}[0][device][name]
                ...      AND  Delete multiple device profiles by names  Test-Profile-1  Test-Profile-2  Test-Profile-3

DeviceGET007 - Query device by name
    Given Create A Device Sample With Associated device-virtual And Test-Profile-1
    When Query Device By Name  Test-Device
    Then Should Return Status Code "200" and device
    And Should Be True  "${content}[device][name]" == "Test-Device"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

DeviceGET008 - Check device exists by name
    Given Create A Device Sample With Associated device-virtual And Test-Profile-2
    When Check Existence Of Device By Name  Test-Device
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

*** Keywords ***
Devices Should Be Linked To Specified Label: ${label}
    ${devices}=  Set Variable  ${content}[devices]
    FOR  ${item}  IN  @{devices}
        List Should Contain Value  ${item}[labels]  ${label}
    END

Children of Device ${name} Should Be Returned
    ${devices}  Set Variable  ${content}[devices]
    ${response_length}  Get Length  ${devices}
    Should Be True  ${response_length} == 3
    FOR  ${item}  IN  @{devices}
        IF  "${item}[name]" == "${Device}[1][device][name]" or "${item}[name]" == "${Device}[2][device][name]"
            Should Be Equal  ${item}[parent]  ${name}
        ELSE IF  "${item}[name]" == "${Device}[3][device][name]"
            Should Be Equal  ${item}[parent]  ${Device}[1][device][name]
        ELSE
            Fail  Device ${item}[name] Should Not Be Queried
        END
    END

Devices Should Be Children Of ${name}
    ${devices}=  Set Variable  ${content}[devices]
    ${response_length}  Get Length  ${devices}
    Should Be True  ${response_length} == 2
    FOR  ${item}  IN  @{devices}
        Should Be Equal  ${item}[parent]  ${name}
    END
