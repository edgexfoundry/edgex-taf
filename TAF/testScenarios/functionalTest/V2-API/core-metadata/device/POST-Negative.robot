*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

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
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  name=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrDevicePOST003 - Create device with adminState validate error
    # Empty adminState
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  adminState=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrDevicePOST004 - Create device with operatingState validate error
    # Empty operatingState
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  operatingState=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrDevicePOST005 - Create device with serviceName validate error
    # Empty serviceName
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  serviceName=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrDevicePOST006 - Create device with profileName validate error
    # Empty profileName
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  profileName=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrDevicePOST007 - Create device with protocols validate error
    # Empty protocols
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  protocols=&{EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrDevicePOST008 - Create device with adminState value validate error
    # Out of optional value for adminState
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  adminState=Invalid
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

ErrDevicePOST009 - Create device with operatingState value validate error
    # Out of optional value for operatingState
    Given Create Multiple Profiles/Services And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  operatingState=Invalid
    When Create Device With ${Device}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete multiple device services by names
    ...                       Device-Service-${index}-1  Device-Service-${index}-2  Device-Service-${index}-3
    ...                  AND  Delete multiple device profiles by names
    ...                       Test-Profile-1  Test-Profile-2  Test-Profile-3

