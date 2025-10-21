*** Settings ***
Documentation  tags
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
             ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
             ...      AND  Create Resources With Tags
             ...      AND  Create Commands With Tags
             ...      AND  Create A Device
Suite Teardown  Run Keywords  Delete device by name Test-Device
                ...      AND  Delete Commands With Tags
                ...      AND  Delete Resources With Tags
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}              tags

*** Test Cases ***
Tags001 - Create events with device-command with tags
#Add tags in device-command, the event will contain tags.
    ${set_data}  Create Dictionary  Command_Float32=10
    When Set specified device Test-Device write command Command_Float32 with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Contain Tags
    And Reading Should Not Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age

Tags002 - Create events with device-resource with tags
#Add tags in device-resource, the reading will contain tags.
    ${set_data}  Create Dictionary  Command_Float64_With_Resource_Tags=10
    When Set specified device Test-Device write command Command_Float64_With_Resource_Tags with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Not Contain Tags
    And Reading Should Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age

Tags003 - Create events with both device-command and device-resource with tags
#Add tags in device-command, the event will contain tags.
#Add tags in device-resource, the reading will contain tags.
    ${set_data}  Create Dictionary  Command_Float32_With_Resource_Tags=10
    When Set specified device Test-Device write command Command_Float32_With_Resource_Tags with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Query All Events
    And Event Should Contain Tags
    And Reading Should Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age

*** Keywords ***
Create Resources With Tags
    ${resource_data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/resource_profile.json  encoding=UTF-8
    ${json_string}=  Evaluate  json.loads(r'''${resource_data}''')  json
    &{tags}=  Create Dictionary  severityLevel=${1}

    @{resource_configs}=    Create List
    ...    Resource_Float32  Float32  0  ${False}
    ...    Resource_Float32_With_Tags  Float32  0  ${True}
    ...    Resource_Float64_With_Tags  Float64  0  ${True}

    FOR  ${index}  ${name}  ${valueType}  ${defaultValue}  ${hasTags}  IN ENUMERATE  @{resource_configs}
        Set To Dictionary  ${json_string}[${index}][resource]  name=${name}
        Set To Dictionary  ${json_string}[${index}][resource][properties]  valueType=${valueType}  defaultValue=${defaultValue}  readWrite=RW
        Remove From Dictionary  ${json_string}[${index}][resource][properties]  units
        Run Keyword If  ${hasTags}  Set To Dictionary  ${json_string}[${index}][resource]  tags=${tags}
    END
    ${len}  Get Length  ${json_string}
    FOR  ${INDEX}  IN RANGE  ${len}
        Set To Dictionary  ${json_string}[${INDEX}]  apiVersion=${API_VERSION}  profileName=${PREFIX}-Sample-Profile
    END
    Set Test Variable  ${resourceProfile}  ${json_string}
    # Create the resource
    Create New resource ${resourceProfile}

Create Commands With Tags
    ${command_data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/command_profile.json  encoding=UTF-8
    ${json_string}=  Evaluate  json.loads(r'''${command_data}''')  json
    &{tags}=  Create Dictionary  severityLevel=${1}
    @{command_configs}=  Create List
    ...  Command_Float32  Resource_Float32  ${True}
    ...  Command_Float32_With_Resource_Tags  Resource_Float32_With_Tags  ${True}
    ...  Command_Float64_With_Resource_Tags  Resource_Float64_With_Tags  ${False}

    FOR  ${index}  ${name}  ${deviceResource}  ${hasTags}  IN ENUMERATE  @{command_configs}
        Set To Dictionary  ${json_string}[${index}][deviceCommand]  name=${name}  isHidden=${False}  readWrite=RW
        Set To Dictionary  ${json_string}[${index}][deviceCommand][resourceOperations][0]  deviceResource=${deviceResource}
        Remove From Dictionary  ${json_string}[${index}][deviceCommand][resourceOperations][0]  DefaultValue
        Run Keyword If  ${hasTags}  Set To Dictionary  ${json_string}[${index}][deviceCommand]  tags=${tags}
    END

    ${len}  Get Length  ${json_string}
    FOR  ${INDEX}  IN RANGE  ${len}
        Set To Dictionary  ${json_string}[${INDEX}]  apiVersion=${API_VERSION}  profileName=${PREFIX}-Sample-Profile
    END
    Set Test Variable  ${commandProfile}  ${json_string}
    # Create the commands
    Create New Command ${commandProfile}

Create A Device
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

Delete Resources With Tags
    @{resource_names}=  Create List
    ...  Resource_Float32
    ...  Resource_Float32_With_Tags
    ...  Resource_Float64_With_Tags
    FOR  ${resource_name}  IN  @{resource_names}
      Delete deviceResource by Name ${resource_name} in ${PREFIX}-Sample-Profile
    END

Delete Commands With Tags
    @{command_names}=  Create List
    ...  Command_Float32
    ...  Command_Float32_With_Resource_Tags
    ...  Command_Float64_With_Resource_Tags
    FOR  ${command_name}  IN  @{command_names}
      Delete deviceCommand by Name ${command_name} in ${PREFIX}-Sample-Profile
    END
