*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device PATCH Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-patch-negative.log

*** Test Cases ***
ErrDevicePATCH001 - Update device with non-existent device name and device name not match id
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[0][device]  name=Non-existent
    And Set To Dictionary  ${Device}[1][device]  id=${content}[0][id]
    When Update Devices ${Device}
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "404"
    And Item Index 1 Should Contain Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH002 - Update device with device name validate error
    # Empty device name
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[1][device]  name=${EMPTY}
    When Update Devices ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH003 - Update device with adminState validate error
    # Empty adminState
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[2][device]  adminState=${EMPTY}
    When Update Devices ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH004 - Update device with operatingState validate error
    # Empty operatingState
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[3][device]  operatingState=${EMPTY}
    When Update Devices ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH005 - Update device with serviceName validate error
    # Empty serviceName
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[0][device]  serviceName=${EMPTY}
    When Update Devices ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH006 - Update device with profileName validate error
    # Empty profileName
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[1][device]  profileName=${EMPTY}
    When Update Devices ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH007 - Update device with protocols validate error
    # Empty protocols
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[2][device]  protocols=&{EMPTY}
    When Update Devices ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH008 - Update device with adminState value validate error
    # Out of optional value for adminState
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[3][device]  adminState=Invalid
    When Update Devices ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH009 - Update device with operatingState value validate error
    # Out of optional value for operatingState
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[1][device]  operatingState=Invalid
    When Update Devices ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample

ErrDevicePATCH010 - Update device with non-existent device name
    Given Create Devices And Generate Multiple Devices Sample For Updating Data
    And Set To Dictionary  ${Device}[2][device]  name=Non-existent
    When Update Devices ${Device}
    And Item Index 0,1,3 Should Contain Status Code "200"
    And Item Index 2 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample, Profiles Sample And Services Sample
