*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords   Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      skipped

*** Variables ***
${SUITE}  Core Metadata Configuration
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_metadata_configuration.log

*** Test Cases ***
CoreMetadata001-Verify device registration blocked when MaxResources is exceeded
# Only one device should be created successfully, and the others should fail due to exceeding resource limit.
    Given Set Config MaxResources to 100 For core-metadata
    When Create Mutiple Devices With Virtual-Sample-Profile
    Then Should Return Status Code "207" And devices
    And Only One Device Should Be Created Successfully
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Device By Name

CoreMetadata002 - Verify device registration blocked when MaxDevices is exceeded
    Given Get Devices totalCount
    And Set Variable  MaxCount  totalCount + 1
    And Set Config MaxDevices to MaxCount For core-metadata
    When Create Mutiple Devices
    And Should Return Status Code "207"
    And Only One Device Should Be Created Successfully
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Delete Device By Name

CoreMetadata003 - Verify device registration blocked when MaxResources is exceeded and MaxDevices is sufficient
# Only one device should be created successfully. The others should fail due to exceeding MaxResources.
    Given Get Devices totalCount
    And Set Config MaxDevices to totalCount + 10 For core-metadata
    And Set Config MaxResources to 100 For core-metadata
    When Create Mutiple Devices With Virtual-Sample-Profile
    Then Should Return Status Code "207"
    And Only One Device Should Be Created Successfully
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Device By Name

CoreMetadata004 - Verify device registration blocked when MaxDevices is exceeded and MaxResources is sufficient
# Only one device should be created successfully. The others should fail due to exceeding MaxDevices.
    Given Get Devices totalCount
    And Set Config MaxDevices to totalCount + 1 For core-metadata
    And Set Config MaxResources to 1000 For core-metadata
    When Create Mutiple Devices With Virtual-Sample-Profile
    Then Should Return Status Code "207"
    And Only One Device Should Be Created Successfully
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Device By Name

CoreMetadata005 - Verify device registration blocked when both MaxDevices and MaxResources are exceeded
# Only one device should be created successfully. The others should fail due to both limits being exceeded.
    Given Get Devices totalCount
    And Set Config MaxDevices to totalCount + 1 For core-metadata
    And Set Config MaxResources to 50 For core-metadata
    When Create Mutiple Devices With Virtual-Sample-Profile
    Then Should Return Status Code "207"
    And Only One Device Should Be Created Successfully
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Device By Name
