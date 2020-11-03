*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Force Tags      v2-api

*** Variables ***
${SUITE}          Core Metadata Device Profile DELETE Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-delete-negative.log
${api_version}    v2

*** Test Cases ***
ErrProfileDELETE001 - Delete device profile by invalid format ID
    # ID format is not uuid
    When Delete Device Profile By ID  d138fccc-f39a4fd0-bd32
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    log to console  ${content}

ErrProfileDELETE002 - Delete device profile by non-existent ID
    ${random_uuid}=  Evaluate  str(uuid.uuid4())
    When Delete Device Profile By ID  ${random_uuid}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    log to console  ${content}

ErrProfileDELETE003 - Delete device profile by ID that used by device
    [Tags]  Skipped  # haven't implemented
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    And Get "id" From Multi-status Item 0
    And Generate A Device Sample  Test-Device-Service  Test-Profile-1
    And Create Device With ${Device}
    When Delete Device Profile By ID  ${item_value}
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

ErrProfileDELETE004 - Delete device profile by non-existent name
    When Delete Device Profile By Name  Invalid_Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileDELETE005 - Delete device profile by name that used by device
    [Tags]  Skipped  # haven't implemented
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-2
    And Create Device Profile ${deviceProfile}
    And Generate A Device Sample  Test-Device-Service  Test-Profile-2
    And Create Device With ${Device}
    When Delete Device Profile By Name  Test-Profile-2
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1
