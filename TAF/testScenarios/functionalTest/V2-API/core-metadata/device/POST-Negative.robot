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
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-post-negative.log
${api_version}    v2

*** Test Cases ***
ErrDevicePOST001 - Create device with duplicate device name
    # 2 devices with same device name
    [Tags]  Skipped
    When Create multiple device
    Then Should Return Status Code "207"
    And Should Have Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "201" And id
    And Item Index 1 Should Contain Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrDevicePOST002 - Create device with device name validate error
    # Empty device name
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-1
    And Set To Dictionary  ${Device}[1][device]  name=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

ErrDevicePOST003 - Create device with adminState validate error
    # Empty adminState
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-1
    And Set To Dictionary  ${Device}[1][device]  adminState=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

ErrDevicePOST004 - Create device with operatingState validate error
    # Empty operatingState
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-2
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-2
    And Set To Dictionary  ${Device}[1][device]  operatingState=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

ErrDevicePOST005 - Create device with serviceName validate error
    # Empty serviceName
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-2
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-2
    And Set To Dictionary  ${Device}[1][device]  serviceName=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

ErrDevicePOST006 - Create device with profileName validate error
    # Empty profileName
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-3
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-3
    And Set To Dictionary  ${Device}[1][device]  profileName=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-3

ErrDevicePOST007 - Create device with protocols validate error
    # Empty protocols
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-3
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-3
    And Set To Dictionary  ${Device}[1][device]  protocols=&{EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-3

ErrDevicePOST008 - Create device with adminState value validate error
    # Out of optional value for adminState
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-4
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-4
    And Set To Dictionary  ${Device}[1][device]  adminState=Invalid
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-4

ErrDevicePOST009 - Create device with operatingState value validate error
    # Out of optional value for operatingState
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-4
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-4
    And Set To Dictionary  ${Device}[1][device]  operatingState=Invalid
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-4

