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
CoreMetadata001-No devices should be created when MaxResources is exceeded
# All devices should not be created due to exceeding resource limit.
    Given Set Config MaxResources to 10 For core-metadata
    When Create Multiple Devices Exceeding MaxResources Limit
    Then Devices Should Not Be Created When MaxResources Value Is Exceeded
    And Total Device Resources Count Should Be Equal or Less Than MaxResources Value
    [Teardown]  Run Keywords  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Devices

CoreMetadata002 -No devices should be created when MaxDevices is exceeded
#Set the MaxDevices value to be less than the current number of devices.
    Given Set Config MaxDevices to 5 For core-metadata
    When Create 4 Devices
    Then Devices Should Not Be Created When MaxDevices Value Is Exceeded
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Delete Devices

CoreMetadata003 - No devices should be created when MaxResources is exceeded and MaxDevices is sufficient
# All devices should not be created due to exceeding resource limit.
    Given Set Config MaxDevices to 10 For core-metadata
    And Set Config MaxResources to 10 For core-metadata
    When Create Multiple Devices Exceeding MaxResources Limit
    Then Devices Should Not Be Created When MaxResources Value Is Exceeded
    And Total Device Count Should Be Equal or Less Than MaxDevices Value
    And Total Device Resources Count Should Be Equal or Less Than MaxResources Value
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Devices

CoreMetadata004 - No devices should be created when MaxDevices is exceeded and MaxResources is sufficient
#Set the MaxDevices value to be less than the current number of devices.
# All devices should not be created due to exceeding MaxDevices.
    Given Set Config MaxDevices to 5 For core-metadata
    And Set Config MaxResources to 1000 For core-metadata
    When Create 4 Devices
    Then Devices Should Not Be Created When MaxDevices Value Is Exceeded
    And Total Device Resources Count Should Be Equal or Less Than MaxResources Value
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Devices

CoreMetadata005 - No devices should be created when both MaxDevices and MaxResources are exceeded
# All devices should not be created due to exceeding resource and device limit.
    Given Set Config MaxDevices to 1 For core-metadata
    And Set Config MaxResources to 10 For core-metadata
    When Create Multiple Devices Exceeding MaxDevices And MaxResources Limits
    Then Devices Should Not Be Created When MaxDevices And MaxResources Values Are Exceeded
    And Total Device Count Should Be Equal or Less Than MaxDevices Value
    And Total Device Resources Count Should Be Equal or Less Than MaxResources Value
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Devices

CoreMetadata006-Only devices within MaxResources limit should be created
# Only one device should be created successfully, and the others should fail due to exceeding resource limit.
    Given Set Config MaxResources to 100 For core-metadata
    When Create Multiple Devices Exceeding MaxResources Limit
    Then Only 1 Devices Should Be Created
    And Total Device Resources Count Should Be Equal or Less Than MaxResources Value
    [Teardown]  Run Keywords  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Devices

CoreMetadata007 -Only devices within MaxDevices limit should be created
    Given Set Config MaxDevices to 5 For core-metadata
    When Create 6 Devices
    Then Only 5 Devices Should Be Created
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Delete Device

CoreMetadata008 - Only devices within MaxResources limit should be created when MaxDevices is sufficient
# Only one device should be created successfully. The others should fail due to exceeding MaxResources.
    Given Set Config MaxDevices to 10 For core-metadata
    And Set Config MaxResources to 100 For core-metadata
    When Create Multiple Devices Exceeding MaxResources Limit
    Then Only 1 Devices Should Be Created
    And Total Device Count Should Be Equal or Less Than MaxDevices Value
    And Total Device Resources Count Should Be Equal or Less Than MaxResources Value
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Devices

CoreMetadata009 - Only devices within MaxDevices limit should be created when MaxResources is sufficient
# Only one device should be created successfully. The others should fail due to exceeding MaxDevices.
    Given Set Config MaxDevices to 5 For core-metadata
    And Set Config MaxResources to 1000 For core-metadata
    When Create 6 Devices
    Then Only 5 Devices Should Be Created
    And Total Device Resources Count Should Be Equal or Less Than MaxResources Value
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Devices

CoreMetadata010 - All devices should be created when MaxDevices and MaxResources are sufficient
# All devices should be created successfully since the MaxDevices and MaxResources values are not limiting.
    Given Set Config MaxDevices to 10 For core-metadata
    And Set Config MaxResources to 1000 For core-metadata
    When Create 5 Devices
    Then All Devices Should Be Created
    And Total Device Count Should Be Equal or Less Than MaxDevices Value
    And Total Device Resources Count Should Be Equal or Less Than MaxResources Value
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete Devices
