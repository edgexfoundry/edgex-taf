*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Service PATCH Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceservice-patch-negative.log

*** Test Cases ***
ErrDevicePATCH001 - Update device service with non-existent name and service name not match id
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[0][service]  name=Non-existent
    And Set To Dictionary  ${deviceService}[2][service]  id=${content}[1][id]
    When Update Device Service ${deviceService}
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "404"
    And Item Index 1 Should Contain Status Code "200"
    And Item Index 2 Should Contain Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Services By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate001 - Update device service with service name validate error
    # no name and no id property
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Remove From Dictionary  ${deviceService}[1][service]  name
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Services By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate002 - Update device service with service name validate error
    # empty name
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[1][service]  name=${EMPTY}
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Services By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate003 - Update device service with baseAddress validate error
    # Empty baseAddress
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[2][service]  baseAddress=${EMPTY}
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Services By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate004 - Update device service with adminState validate error
    # Empty adminState
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[1][service]  adminState=${EMPTY}
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Services By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

ErrDevicePATCHValidate005 - Update device service with adminState value validate error
    # Out of optional value for adminState
    Given Generate Multiple Device Services Sample
    And Create Device Service ${deviceService}
    And Generate Multiple Device Services Sample For Updating
    And Set To Dictionary  ${deviceService}[1][service]  adminState=Invalid
    When Update Device Service ${deviceService}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Device Services By Names  Device-Service-${index}-1  Device-Service-${index}-2
    ...                                                  Device-Service-${index}-3

