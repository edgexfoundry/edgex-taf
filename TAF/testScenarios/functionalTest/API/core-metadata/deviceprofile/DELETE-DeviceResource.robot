*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device Profile DELETE Device Resource Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-delete-deviceresource-positive.log

*** Test Cases ***
ProfileResourceDELETE001 - Delete deviceResource by name
    Given Set Test Variable  ${profile_name}  Test-Profile-1
    And Generate A Device Profile Sample  ${profile_name}
    And Create device profile ${deviceProfile}
    When Delete Unused deviceResource From ${profile_name}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Resource ${resource_name} In ${profile_name} Should Be Deleted
    [Teardown]  Delete device profile by name  ${profile_name}

ErrProfileResourceDELETE001 - Delete deviceResource by non-existent deviceResource name
    # non-existent deviceResource name
    Given Set Test Variable  ${profile_name}  Test-Profile-1
    And Generate A Device Profile Sample  ${profile_name}
    And Create device profile ${deviceProfile}
    When Delete deviceResource by Name not-existent in ${profile_name}
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name  ${profile_name}

ErrProfileResourceDELETE002 - Delete deviceResource by non-existent device profile
    # non-existent deviceResource name
    When Delete deviceResource by Name DeviceValue_String_R in Test-Profile-1
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileResourceDELETE003 - Delete deviceResource which profile used by device
    Given Set Test Variable  ${profile_name}  Test-Profile-2
    And Create A Device Sample With Associated device-virtual And ${profile_name}
    When Delete Unused deviceResource From ${profile_name}
    Then Should Return Status Code "409"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Resource ${resource_name} In ${profile_name} Should Not Be Deleted
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  ${profile_name}

ErrProfileResourceDELETE004 - Delete deviceResource which used by deviceCommand
    Given Set Test Variable  ${profile_name}  Test-Profile-3
    And Generate A Device Profile Sample  ${profile_name}
    And Create device profile ${deviceProfile}
    When Delete Used deviceResource From ${profile_name}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Resource ${resource_name} In ${profile_name} Should Not Be Deleted
    [Teardown]  Delete Device Profile By Name  ${profile_name}

ErrProfileResourceDELETE005 - Delete deviceResource when StrictDeviceProfileChanges config is enabled
    # StrictDeviceProfileChanges config is true
    Given Set ProfileChange.StrictDeviceProfileChanges to true For Core-Metadata On Registry Service
    And Set Test Variable  ${profile_name}  Test-Profile-4
    And Generate A Device Profile Sample  ${profile_name}
    And Create device profile ${deviceProfile}
    When Delete Unused deviceResource From ${profile_name}
    Then Should Return Status Code "423"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Resource ${resource_name} In ${profile_name} Should Not Be Deleted
    [Teardown]  Run Keywords  Set ProfileChange.StrictDeviceProfileChanges to false For Core-Metadata On Registry Service
    ...                  AND  Delete Device Profile By Name  ${profile_name}

ProfileResourceDELETE006 - Delete deviceResource by name which contains Chinese and space character
    Given Set Test Variable  ${test_profile}  Test-Profile-5
    And Generate A Device Profile Sample  ${test_profile}
    And Create device profile ${deviceProfile}
    When Delete Unused deviceResource From ${test_profile}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Device Resource ${resource_name} In ${test_profile} Should Be Deleted
    [Teardown]  Delete device profile by name  ${test_profile}

*** Keywords ***
Delete ${action} deviceResource From ${profile}
    Query device profile by name  ${profile}
    ${resources}  Run Keyword If  "${action}" == "Unused"  Get Unused Device Resources From Profile
                  ...    ELSE IF  "${action}" == "Used"  Get Used Device Resources From Profile
                  ...    ELSE     Fail  Incorrect Action !!
    ${resource}  Evaluate  random.choice(@{resources})  random
    Delete deviceResource by Name ${resource} in ${profile}
    Set Test Variable  ${resource_name}  ${resource}

Get All Device Resources From Profile
    [Arguments]  ${profile}
    ${resources}  Create List
    ${resource_amount}  Get Length  ${profile}[profile][deviceResources]
    FOR  ${INDEX}  IN RANGE  ${resource_amount}
        ${name}  Set Variable  ${profile}[profile][deviceResources][${INDEX}][name]
        Append To List  ${resources}  ${name}
    END
    RETURN  ${resources}

Get Unused Device Resources From Profile
    ${resources}  Get All Device Resources From Profile  ${content}
    ${usedResource_list}  Get Used Device Resources From Profile
    FOR  ${usedResource}  IN  @{usedResource_list}
        Remove Values From List  ${resources}  ${usedResource}
    END
    RETURN  ${resources}

Get Used Device Resources From Profile
    ${allUsedResources}  Create List
    ${command_amount}  Get Length  ${content}[profile][deviceCommands]
    FOR  ${INDEX}  IN RANGE  ${command_amount}
        ${resource_amount}  Get Length  ${content}[profile][deviceCommands][${INDEX}][resourceOperations]
        FOR  ${SUB_INDEX}  IN RANGE  ${resource_amount}
            ${name}  Set Variable  ${content}[profile][deviceCommands][${INDEX}][resourceOperations][${SUB_INDEX}][deviceResource]
            Append To List  ${allUsedResources}  ${name}
        END
    END
    ${usedResources}  Remove Duplicates  ${allUsedResources}
    RETURN  ${usedResources}

Device Resource ${resource_name} In ${profile} Should Be Deleted
    Query device profile by name  ${profile}
    ${resources}  Get All Device Resources From Profile  ${content}
    List Should Not Contain Value  ${resources}  ${resource_name}  The DeviceResource is still existed

Device Resource ${resource_name} In ${profile} Should Not Be Deleted
    Query device profile by name  ${profile}
    ${resources}  Get All Device Resources From Profile  ${content}
    List Should Contain Value  ${resources}  ${resource_name}  The DeviceResource is not existed
