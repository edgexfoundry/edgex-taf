*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

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
    [Tags]  Skipped
    Given Create A Device Profile
    And Create A Device
    When Delete Device Profile By ID
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileDELETE004 - Delete device profile by non-existent name
    When Delete Device Profile By Name  Invalid_Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileDELETE005 - Delete device profile by name that used by device
    [Tags]  Skipped
    Given Create A Device Profile
    And Create A Device
    When Delete Device Profile By Name
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
