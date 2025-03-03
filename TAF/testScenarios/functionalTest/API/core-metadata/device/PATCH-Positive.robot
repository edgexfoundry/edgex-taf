*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Delete all events by age
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device PATCH Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-patch-positive.log

*** Test Cases ***
DevicePATCH001 - Update device
    # operatingState, adminState, labels, protocols
    [Tags]  SmokeTest
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    When Update Devices ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Data Should Be Updated
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePATCH002 - Update device with device service and profile
    # profileName, serviceName
    Given Create Devices And Generate Multiple Devices Sample For Updating Profile/Device
    When Update Devices ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Profile/Device Should Be Updated
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePATCH003 - Update device with empty protocol
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[2][device]  protocols=&{EMPTY}
    When Update Devices ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePATCH004 - Update device with empty profileName
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[1][device]  profileName=${EMPTY}
    When Update Devices ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePATCH005 - Update device with autoEvent retention
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Generate autoEvent With Retention Example
    And Set To Dictionary  ${Device}[3][device]  autoEvents=${autoEvents}
    When Update Devices ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And autoEvent Retention Should Be Added To Device
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

*** Keywords ***
Device ${type} Should Be Updated
    ${list}=  Create List  Test-Device  Test-Device-Locked  Test-Device-Disabled  Test-Device-AutoEvents
    ${expected_keys}=  Create List  name  operatingState  adminState  protocols  serviceName  profileName
    FOR  ${device}  IN  @{list}
        Query Device By Name  ${device}
        ${keys}=  Get Dictionary Keys  ${content}[device]
        List Should Contain Sub List  ${keys}  ${expected_keys}
        Run Keyword If  "${type}" == "Data" and "${device}" == "Test-Device"
        ...             List Should Contain Value  ${content}[device][labels]  device-update
        Run Keyword If  "${type}" == "Data" and "${device}" == "Test-Device-Locked"
        ...             Should Be Equal  ${content}[device][adminState]  UNLOCKED
        ...    ELSE IF  "${device}" == "Test-Device-Locked"
        ...             Should Be Equal  ${content}[device][serviceName]  ${device_service_list}[2]
        Run Keyword If  "${type}" == "Data" and "${device}" == "Test-Device-Disabled"
        ...             Should Be Equal  ${content}[device][operatingState]  UP
        ...    ELSE IF  "${device}" == "Test-Device-Disabled"
        ...             Should Be Equal  ${content}[device][profileName]  Test-Profile-3
        Run Keyword If  "${type}" == "Data" and "${device}" == "Test-Device-AutoEvents"
        ...             Should Be Equal  ${content}[device][protocols][other][Address]  simple02
    END

autoEvent Retention Should Be Added To Device
    Query Device By Name  Test-Device-AutoEvents
    ${response_retention}  Convert To Dictionary  ${content}[device][autoEvents][0][retention]
    Dictionaries Should Be Equal  ${retention}  ${response_retention}

Generate autoEvent With Retention Example
    ${profile}=  Load yaml file "core-metadata/deviceprofile/Test-Profile-1.yaml" and convert to dictionary
    ${retention}  Create Dictionary  maxCap=${50}  minCap=${5}  duration=10m
    ${autoEvent}  Set autoEvents values  10s  true  ${profile}[deviceResources][0][name]  ${retention}
    ${autoEvents}  Create List  ${autoEvent}
    Set Test Variable  ${retention}  ${retention}
    Set Test Variable  ${autoEvents}  ${autoEvents}
