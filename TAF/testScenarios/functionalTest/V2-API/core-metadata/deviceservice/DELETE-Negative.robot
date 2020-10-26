*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device Service DELETE Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceservice-delete-negative.log
${api_version}    v2

*** Test Cases ***
ErrServiceDELETE001 - Delete device service by ID with invalid id format
    # use non uuid format, like d138fccc-f39a4fd0-bd32
    When Delete Device Service By ID  d138fccc-f39a4fd0-bd32
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrServiceDELETE002 - Delete device service by ID that used by device
    [Tags]  Skipped  # haven't implemented
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Get "id" From Multi-status Item 0
    And Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    And Generate A Device Sample  Test-Device-Service  Test-Profile-1
    And Create Device With ${Device}
    When Delete Device Service By ID  ${item_value}
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

ErrServiceDELETE003 - Delete device service by ID with non-existent id
    ${random_uuid}=  Evaluate  str(uuid.uuid4())
    When Delete Device Service By ID  ${random_uuid}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrServiceDELETE004 - Delete device service by name that used by device
    [Tags]  Skipped  # haven't implemented
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-2
    And Create Device Profile ${deviceProfile}
    And Generate A Device Sample  Test-Device-Service  Test-Profile-2
    And Create Device With ${Device}
    When Delete Device Service By Name  Test-Device-Service
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

ErrServiceDELETE005 - Delete device service by name with non-existent service name
    When Delete Device Service By Name  Invalid_Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
