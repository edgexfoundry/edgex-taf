*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run Keywords   Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}  Core Metadata Configuration
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core_metadata_configuration.log

*** Test Cases ***
CoreMetadata001-No devices should be created when MaxResources is exceeded
# All devices should not be created due to exceeding resource limit.
#The number of deviceResources in Virtual-Sample-Profile is 40.
    Given Get Current Resource Count
    And Set Config MaxResources to ${current_resource_count + 10} For core-metadata
    When Create 1 Devices For device-virtual
    Then Devices Should Not Be Created
    And Total Device Resources Count Should Be Equal or Less Than  ${current_resource_count + 10}
    [Teardown]  Run Keywords  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata002 -No devices should be created when MaxDevices is exceeded
#Set the MaxDevices value to be less than the current number of devices.
    Given Get Current Device Count
    And Set Config MaxDevices to ${current_device_count-1} For core-metadata
    When Create 1 Devices For device-virtual
    Then Devices Should Not Be Created
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata003 - No devices should be created when MaxResources is exceeded and MaxDevices is sufficient
# All devices should not be created due to exceeding resource limit.
#The number of deviceResources in Virtual-Sample-Profile is 40.
    Given Get Current Device and Resource Count
    And Set Config MaxDevices to ${current_device_count + 10} For core-metadata
    And Set Config MaxResources to ${current_resource_count + 10} For core-metadata
    When Create 1 Devices For device-virtual
    Then Devices Should Not Be Created
    And Total Device Resources Count Should Be Equal or Less Than  ${current_resource_count + 10}
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata004 - No devices should be created when MaxDevices is exceeded and MaxResources is sufficient
#Set the MaxDevices value to be less than the current number of devices.
# All devices should not be created due to exceeding MaxDevices.
    Given Get Current Device and Resource Count
    And Set Config MaxDevices to ${current_device_count - 1} For core-metadata
    And Set Config MaxResources to ${current_resource_count + 100} For core-metadata
    When Create 1 Devices For device-virtual
    Then Devices Should Not Be Created
    And Total Device Resources Count Should Be Equal or Less Than  ${current_resource_count + 100}
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata005 - No devices should be created when both MaxDevices and MaxResources are exceeded
# All devices should not be created due to exceeding resource and device limit.
    Given Get Current Device and Resource Count
    And Set Config MaxDevices to ${current_device_count - 1} For core-metadata
    And Set Config MaxResources to ${current_resource_count + 10} For core-metadata
    When Create 1 Devices For device-virtual
    Then Devices Should Not Be Created
    And Total Device Resources Count Should Be Equal or Less Than  ${current_resource_count + 10}
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata006-Only devices within MaxResources limit should be created
# Only one device should be created successfully, and the others should fail due to exceeding resource limit.
#The number of deviceResources in Virtual-Sample-Profile is 40.
    Given Get Current Resource Count
    And Set Config MaxResources to ${current_resource_count + 40} For core-metadata
    When Create 2 Devices For device-virtual
    Then Devices Should Be Created  1
    And Total Device Resources Count Should Be Equal or Less Than  ${current_resource_count + 40}
    [Teardown]  Run Keywords  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata007 -Only devices within MaxDevices limit should be created
    Given Get Current Device Count
    Given Set Config MaxDevices to ${current_device_count + 2} For core-metadata
    When Create 2 Devices For device-virtual
    Then Devices Should Be Created  2
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata008 - Only devices within MaxResources limit should be created when MaxDevices is sufficient
# Only one device should be created successfully. The others should fail due to exceeding MaxResources.
#The number of deviceResources in Virtual-Sample-Profile is 40.
    Given Get Current Device and Resource Count
    And Set Config MaxDevices to ${current_device_count + 10} For core-metadata
    And Set Config MaxResources to ${current_resource_count + 40} For core-metadata
    When Create 2 Devices For device-virtual
    Then Devices Should Be Created  1
    And Total Device Resources Count Should Be Equal or Less Than  ${current_resource_count + 40}
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata009 - Only devices within MaxDevices limit should be created when MaxResources is sufficient
# Only one device should be created successfully. The others should fail due to exceeding MaxDevices.
    Given Get Current Device and Resource Count
    And Set Config MaxDevices to ${current_device_count + 2} For core-metadata
    And Set Config MaxResources to ${current_resource_count + 300} For core-metadata
    When Create 3 Devices For device-virtual
    Then Devices Should Be Created  2
    And Total Device Resources Count Should Be Equal or Less Than  ${current_resource_count + 300}
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

CoreMetadata010 - All devices should be created when MaxDevices and MaxResources are sufficient
# All devices should be created successfully since the MaxDevices and MaxResources values are not limiting.
    Given Get Current Device and Resource Count
    And Set Config MaxDevices to ${current_device_count + 10} For core-metadata
    And Set Config MaxResources to ${current_resource_count + 300} For core-metadata
    When Create 3 Devices For device-virtual
    Then Devices Should Be Created  3
    And Total Device Resources Count Should Be Equal or Less Than  ${current_resource_count + 300}
    [Teardown]  Run Keywords  Set Config MaxDevices to 0 For core-metadata
                ...      AND  Set Config MaxResources to 0 For core-metadata
                ...      AND  Delete multiple devices by names  @{device_list}

*** Keywords ***
Get Current Device Count
    Query All Devices
    Set Test Variable  ${current_device_count}  ${content}[totalCount]

Get Current Resource Count
    ${total_resource_count}=  Set Variable  0
    Query All Devices
    FOR  ${device}  IN  @{content}[devices]
        ${profile_name}=  Set Variable  ${device}[profileName]
        Query Device Profile By Name  ${profile_name}
        ${resource_count}=  Get Length  ${content}[profile][deviceResources]
        ${total_resource_count}=  Evaluate  ${total_resource_count} + ${resource_count}
    END
    Set Test Variable  ${current_resource_count}  ${total_resource_count}

Get Current Device and Resource Count
    Get Current Device Count
    Get Current Resource Count

Set Config ${config} to ${value} For core-metadata
    ${path}=  Set Variable  /core-metadata/Writable/${config}
    Update Service Configuration  ${path}  ${value}

Devices Should Not Be Created
    Query All Devices
     @{existing_devices}=  Create List
    FOR  ${device}  IN  @{content}[devices]
        ${device_name}=  Get From Dictionary  ${device}  name
        Append To List  ${existing_devices}  ${device_name}
    END
    FOR  ${device_name}  IN  @{device_list}
        List Should Not Contain Value  ${existing_devices}  ${device_name}
    END

Devices Should Be Created
    [Arguments]  ${expected}
    Query All Devices
    @{existing_devices}=  Create List
    FOR  ${device}  IN  @{content}[devices]
        ${device_name}=  Get From Dictionary  ${device}  name
        Append To List  ${existing_devices}  ${device_name}
    END
    @{expected_devices}=  Create List
    FOR  ${index}  IN RANGE  ${expected}
        ${name}=  Set Variable  Command-Device-${index}
        Append To List  ${expected_devices}  ${name}
        List Should Contain Value  ${existing_devices}  ${name}
    END
    FOR  ${device_name}  IN  @{device_list}
        IF  "${device_name}" not in ${expected_devices}
            List Should Not Contain Value  ${existing_devices}  ${device_name}
        END
    END

Total Device Resources Count Should Be Equal or Less Than
    [Arguments]  ${expected_limit}
    Get Current Resource Count
    Should Be True  ${current_resource_count} <= ${expected_limit}
