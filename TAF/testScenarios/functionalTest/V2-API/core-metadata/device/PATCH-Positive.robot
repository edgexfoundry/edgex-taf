*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device PATCH Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-patch-positive.log
${api_version}    v2

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
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

DevicePATCH002 - Update device with device service and profile
    # profileName, serviceName
    Given Create Devices And Generate Multiple Devices Sample For Updating Profile/Device
    When Update Devices ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Profile/Device Should Be Updated
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

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
        ...             Should Be Equal  ${content}[device][serviceName]  Device-Service-${index}-3
        Run Keyword If  "${type}" == "Data" and "${device}" == "Test-Device-Disabled"
        ...             Should Be Equal  ${content}[device][operatingState]  UP
        ...    ELSE IF  "${device}" == "Test-Device-Disabled"
        ...             Should Be Equal  ${content}[device][profileName]  Test-Profile-3
        Run Keyword If  "${type}" == "Data" and "${device}" == "Test-Device-AutoEvents"
        ...             Should Be Equal  ${content}[device][protocols][other][Address]  simple02
    END

