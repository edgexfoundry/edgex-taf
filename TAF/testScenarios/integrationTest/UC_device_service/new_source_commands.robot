*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Delete all events by age
                ...      AND  Run Teardown Keywords
Force Tags  MessageBus=redis

*** Variables ***
${SUITE}              Get Command For New Resource And Command

*** Test Cases ***
GETCommand001 - Retrieve device reading after creating a new resource
    Given Set Test Data Type
    And Generate A Device Resource
    And Create New resource ${new_resource}
    And Create Device For ${SERVICE_NAME} With Name Query-New-Resource
    When Invoke Get command by device ${device_name} and command ${resource_name}
    Then Should return status code "200"
    And Value should be "${dataType_upper}"
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Delete deviceResource by Name ${resource_name} in ${PREFIX}-Sample-Profile

GETCommand002 - Retrieve device reading after creating a new resource with new command
    Given Set Test Data Type
    And Generate A Device Resource
    And Create New resource ${new_resource}
    And Generate A Device Command
    And Create New Command ${new_command}
    And Create Device For ${SERVICE_NAME} With Name Query-New-Command
    When Invoke Get command by device ${device_name} and command ${command_name}
    Then Should return status code "200"
    And Value should be "${dataType_upper}"
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Delete deviceCommand by Name ${command_name} in ${PREFIX}-Sample-Profile
                ...      AND  Delete deviceResource by Name ${resource_name} in ${PREFIX}-Sample-Profile

SETCommand001 - Set device reading after creating a new resource
    Given Set Test Data Type And Generate Test Value
    And Generate A Device Resource
    And Create New resource ${new_resource}
    And Create Device For ${SERVICE_NAME} With Name Query-New-Resource
    When Invoke SET command by device ${device_name} and command ${resource_name} with request body ${resource_name}:${set_reading_value}
    Then Should return status code "200"
    And Get Command Value Should Be The Same As Set Value ${set_reading_value}
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Delete deviceResource by Name ${resource_name} in ${PREFIX}-Sample-Profile

SETCommand002 - Set device reading after creating a new resource with new command
    Given Set Test Data Type And Generate Test Value
    And Generate A Device Resource
    And Create New resource ${new_resource}
    And Generate A Device Command
    And Create New Command ${new_command}
    And Create Device For ${SERVICE_NAME} With Name Query-New-Command
    When Invoke SET command by device ${device_name} and command ${command_name} with request body ${resource_name}:${set_reading_value}
    Then Should return status code "200"
    And Get Command Value Should Be The Same As Set Value ${set_reading_value}
    [Teardown]  Run Keywords  Delete device by name ${device_name}
                ...      AND  Delete deviceCommand by Name ${command_name} in ${PREFIX}-Sample-Profile
                ...      AND  Delete deviceResource by Name ${resource_name} in ${PREFIX}-Sample-Profile

*** Keywords ***
Generate A Device Resource
    Set Test Variable  ${resource_name}  NewTemperature
    # Create resource properties
    ${properties_dict}  Create Dictionary
    Set To Dictionary  ${properties_dict}  valueType=${dataType}
    Set To Dictionary  ${properties_dict}  readWrite=RW
    # Create resource
    ${resource_dict}  Create Dictionary
    Set To Dictionary  ${resource_dict}   name=${resource_name}
    Set To Dictionary  ${resource_dict}   properties=${properties_dict}
    # Entire device resource
    ${entire_resource_dict}  Create Dictionary
    Set To Dictionary  ${entire_resource_dict}  apiVersion=${API_VERSION}
    Set To Dictionary  ${entire_resource_dict}   profileName=${PREFIX}-Sample-Profile
    Set To Dictionary  ${entire_resource_dict}   resource=${resource_dict}
    ${resource_list}  Create List  ${entire_resource_dict}
    ${resource}  Evaluate  json.dumps(${resource_list})
    ${resource}  Evaluate  json.loads('''${resource}''')
    Set Test Variable  ${new_resource}  ${resource}

Generate A Device Command
    Set Test Variable  ${command_name}  GetNewTemperature
    # Create resourceOperations List
    ${resourceOperations_dict}  Create Dictionary
    Set To Dictionary  ${resourceOperations_dict}  deviceResource=${resource_name}
    ${resourceOperations_list}  Create List  ${resourceOperations_dict}
    # Create deviceCommand
    ${deviceCommand_dict}  Create Dictionary
    Set To Dictionary  ${deviceCommand_dict}  name=${command_name}
    Set To Dictionary  ${deviceCommand_dict}  readWrite=RW
    Set To Dictionary  ${deviceCommand_dict}  resourceOperations=${resourceOperations_list}
    # Entire deviceCommand
    ${command_dict}  Create Dictionary
    Set To Dictionary  ${command_dict}   apiVersion=${API_VERSION}
    Set To Dictionary  ${command_dict}   profileName=${PREFIX}-Sample-Profile
    Set To Dictionary  ${command_dict}  deviceCommand=${deviceCommand_dict}
    ${command_list}  Create List  ${command_dict}
    ${command}  Evaluate  json.dumps(${command_list})
    ${command}  Evaluate  json.loads('''${command}''')
    Set Test Variable  ${new_command}  ${command}

Set Test Data Type
    Set Test Variable   ${dataType}  Int16
    ${dataType_upper}  Convert To Upper Case  ${dataType}
    Set Test Variable  ${dataType_upper}  ${dataType_upper}  # Use to validate value

Set Test Data Type And Generate Test Value
    Set Test Data Type
    ${random_value}  Get reading value with data type "${dataType_upper}"
    ${set_reading_value}  convert to string  ${random_value}
    Set Test Variable  ${set_reading_value}  ${set_reading_value}

Get Command Value Should Be The Same As Set Value ${value}
    Invoke Get command by device ${device_name} and command ${resource_name}
    Should Be Equal  ${get_reading_value}  ${value}
