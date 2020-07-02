*** Settings ***
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token

*** Variables ***
${SUITE}              Device

*** Test Cases ***
DeviceProfile_TC0001 - ValueDescriptor is created after initializing device service
    [Tags]  Backward
    ${device_profile_name}=  set variable  Sample-Profile
    Then DeviceProfile "${device_profile_name}" should be created in Core Metadata
    And DS should create ValueDescriptors in Core Data according to DeviceProfile "${device_profile_name}"

*** Keywords ***
DeviceProfile "${device_profile_name}" should be created in Core Metadata
    Query device profile by name    ${device_profile_name}
    Should return status code "200"

DS should create ValueDescriptors in Core Data according to DeviceProfile "${device_profile_name}"
    @{resources}=  Retrieve all resource names for the device profile "${device_profile_name}"
    :For    ${resource_name}   IN    @{resources}
    \   run keyword and continue on failure  Query value descriptor for name "${resource_name}"

Retrieve all resource names for the device profile "${device_profile_name}"
    ${device_profile_content}=  Query device profile by name    ${device_profile_name}
    ${device_profile_json}=  evaluate  json.loads('''${device_profile_content}''')  json
    ${resource_length}=  get length  ${device_profile_json}[deviceResources]
    @{resource_names}=   create list
    :For    ${INDEX}  IN RANGE  ${resource_length}
    \   Append To List    ${resource_names}    ${device_profile_json}[deviceResources][${INDEX}][name]
    [Return]   ${resource_names}
