*** Settings ***
Documentation  tags
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Resource     TAF/testCaseModules/keywords/core-metedata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
             ...      AND  Create A Device With device-command with tags
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Delete Resources For Tags
                ...      AND  Delete Commands For Tags
                ...      AND  Delete device by name Test-Device
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}              tags

*** Test Cases ***
Tags001 - Create events with device-command with tags
#Add tags in device-command, the event will contain tags.
    ${set_data}  Create Dictionary  Virtual_GenerateDeviceValue_FLOAT32_RW=10
    When Set specified device Test-Device write command Virtual_GenerateDeviceValue_FLOAT32_RW with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Contain Tags
    And Reading Should Not Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age

Tags002 - Create events with device-resource with tags
#Add tags in device-resource, the reading will contain tags.
    ${set_data}  Create Dictionary  Virtual_GenerateDeviceValue_INT8_RW=10
    When Set specified device Test-Device write command Virtual_GenerateDeviceValue_INT8_RW with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Not Contain Tags
    And Reading Should Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age

Tags003 - Create events with both device-command and device-resource with tags
#Add tags in device-command, the event will contain tags.
#Add tags in device-resource, the reading will contain tags.
    ${set_data}  Create Dictionary  Virtual_GenerateDeviceValue_FLOAT64_RW=10
    When Set specified device Test-Device write command Virtual_GenerateDeviceValue_FLOAT64_RW with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Query All Events
    And Event Should Contain Tags
    And Reading Should Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age
                ...  AND  Delete device by name Test-Device

*** Keywords ***
Create Resources For Tags
    ${profile_data}=    Load yaml file "core-metadata/deviceprofile/Test-Profile-tags.yaml" and convert to dictionary
    FOR    ${resource}    IN    @{profile_data}[deviceResources]
        # Create resource dictionary from YAML
        ${resource_dict}=    Create Dictionary
        Set To Dictionary    ${resource_dict}    name=${resource}[name]
        Set To Dictionary    ${resource_dict}    description=${resource}[description]
        Set To Dictionary    ${resource_dict}    properties=${resource}[properties]

        # Add tags if exists
        ${has_tags}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${resource}    tags
        Run Keyword If    ${has_tags}
        ...    Set To Dictionary    ${resource_dict}    tags=${resource}[tags]

        # Create entire resource dictionary
        ${entire_resource_dict}=    Create Dictionary
        Set To Dictionary    ${entire_resource_dict}    apiVersion=${API_VERSION}
        Set To Dictionary    ${entire_resource_dict}    profileName=${PREFIX}-Sample-Profile
        Set To Dictionary    ${entire_resource_dict}    resource=${resource_dict}

        # Create list and convert to JSON
        ${resource_list}=    Create List    ${entire_resource_dict}
        ${resource_json}=    Evaluate    json.dumps(${resource_list})
        ${resource_entity}=    Evaluate    json.loads('''${resource_json}''')

        # Create the resource
        Create New resource ${resource_entity}
    END

Create Commands For Tags
    ${profile_data}=    Load yaml file "core-metadata/deviceprofile/Test-Profile-tags.yaml" and convert to dictionary

    FOR    ${command}    IN    @{profile_data}[deviceCommands]
        # Create deviceCommand dictionary from YAML
        ${deviceCommand_dict}=    Create Dictionary
        Set To Dictionary    ${deviceCommand_dict}    name=${command}[name]
        Set To Dictionary    ${deviceCommand_dict}    isHidden=${command}[isHidden]
        Set To Dictionary    ${deviceCommand_dict}    readWrite=${command}[readWrite]
        Set To Dictionary    ${deviceCommand_dict}    resourceOperations=${command}[resourceOperations]

        # Add tags if exists
        ${has_tags}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${command}    tags
        Run Keyword If    ${has_tags}
        ...    Set To Dictionary    ${deviceCommand_dict}    tags=${command}[tags]

        # Entire deviceCommand
        ${command_dict}=    Create Dictionary
        Set To Dictionary    ${command_dict}    apiVersion=${API_VERSION}
        Set To Dictionary    ${command_dict}    profileName=${PREFIX}-Sample-Profile
        Set To Dictionary    ${command_dict}    deviceCommand=${deviceCommand_dict}

        # Create list and convert to JSON
        ${command_list}=    Create List    ${command_dict}
        ${command_json}=    Evaluate    json.dumps(${command_list})
        ${command_entity}=    Evaluate    json.loads('''${command_json}''')

        # Create the command
        Create New command ${command_entity}
    END

Create A Device With device-command with tags
    Create Resources For Tags
    Create Commands For Tags
    ${device_1}=  Set device values  device-virtual  ${PREFIX}-Sample-Profile
    Generate Devices  ${device_1}
    Create Device With ${Device}

${field} Should Contain Tags
    Query all events
    IF  '${field}' == 'Event'
      ${target}=  Set Variable  ${content}[events][0]
    ELSE
      ${target}=  Set Variable  ${content}[events][0][readings][0]
    END
    Dictionary Should Contain Key  ${target}  tags
    Should Be Equal As Integers  ${target}[tags][severityLevel]  1

${field} Should Not Contain Tags
    Query all events
    IF  '${field}' == 'Event'
      ${target}=  Set Variable  ${content}[events][0]
    ELSE
      ${target}=  Set Variable  ${content}[events][0][readings][0]
    END
    Dictionary Should Not Contain Key  ${target}  tags

Delete Resources For Tags
    ${profile_data}=    Load yaml file "core-metadata/deviceprofile/Test-Profile-tags.yaml" and convert to dictionary

    FOR    ${resource}    IN    @{profile_data}[deviceResources]
        Delete deviceResource by Name ${resource}[name] in ${PREFIX}-Sample-Profile
    END

Delete Commands For Tags
    ${profile_data}=    Load yaml file "core-metadata/deviceprofile/Test-Profile-tags.yaml" and convert to dictionary

    FOR    ${command}    IN    @{profile_data}[deviceCommands]
        Delete deviceCommand by Name ${command}[name] in ${PREFIX}-Sample-Profile
    END
