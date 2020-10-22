*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device Service PATCH Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceservice-patch-negative.log
${api_version}    v2

*** Test Cases ***
ErrDevicePATCH001 - Update device with use duplicate device service name
    [Tags]  Skipped
    Given Create Multiple Device Services
    When Update Multiple Devices Services
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "409"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrDevicePATCH002 - Update device with non-existent device service name
    # non-existent service name
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[2][service]  name=Non-existent
    When Update Device Service ${deviceService}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 2 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate001 - Update device with service name validate error
    # no name and no id property
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Remove From Dictionary  ${deviceService}[1][service]  name
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate002 - Update device with service name validate error
    # empty name
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[1][service]  name=${EMPTY}
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate003 - Update device with baseAddress validate error
    # Empty baseAddress
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[2][service]  baseAddress=${EMPTY}
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate004 - Update device with adminState validate error
    # Empty adminState
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[1][service]  adminState=${EMPTY}
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate005 - Update device with adminState value validate error
    # Out of optional value for adminState
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[1][service]  adminState=Invalid
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate006 - Update device with operatingState validate error
    # Empty operatingState
    # operatingState property will be removed soon
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[1][service]  operatingState=${EMPTY}
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate007 - Update device with operatingState validate error
    # Out of optional value for operatingState
    # operatingState property will be removed soon
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[1][service]  operatingState=Invalid
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Servics By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

