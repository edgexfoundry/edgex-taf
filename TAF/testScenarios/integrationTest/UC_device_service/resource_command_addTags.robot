*** Settings ***
Documentation  profile
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-command/coreCommandAPI.robot
Resource     TAF/testCaseModules/keywords/core-metedata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Run Teardown Keywords

*** Variables ***
${SUITE}              Profile

*** Test Cases ***
Tags001 - Create events with device-command with tags
#Add tags in device-command, the event will contain tags.
    ${set_data}  Create Dictionary  Virtual_GenerateDeviceValue_FLOAT32_RW=10
    Given Create A Device With device-command with tags
    When Set specified device Test-Device write command Virtual_GenerateDeviceValue_FLOAT32_RW with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Contain Tags
    And Reading Should Not Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age
                ...  AND  Delete device by name Test-Device
                ...  AND  Delete device profile by name  Test-Profile-tags

Tags002 - Create events with device-resource with tags
#Add tags in device-resource, the reading will contain tags.
    ${set_data}  Create Dictionary  Virtual_GenerateDeviceValue_INT8_RW=10
    Given Create A Device With device-command with tags
    When Set specified device Test-Device write command Virtual_GenerateDeviceValue_INT8_RW with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Not Contain Tags
    And Reading Should Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age
                ...  AND  Delete device by name Test-Device
                ...  AND  Delete device profile by name  Test-Profile-tags

Tags003 - Create events with both device-command and device-resource with tags
#Add tags in device-command, the event will contain tags.
#Add tags in device-resource, the reading will contain tags.
    ${set_data}  Create Dictionary  Virtual_GenerateDeviceValue_FLOAT64_RW=10
    Given Create A Device With device-command with tags
    When Set specified device Test-Device write command Virtual_GenerateDeviceValue_FLOAT64_RW with ${set_data}
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Query All Events
    And Event Should Contain Tags
    And Reading Should Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age
                ...  AND  Delete device by name Test-Device
                ...  AND  Delete device profile by name  Test-Profile-tags

*** Keywords ***
Create a Profile With device-command with tags
    Generate A Device Profile Sample  Test-Profile-tags
    Create device profile ${deviceProfile}

Create A Device With device-command with tags
    Create a Profile With device-command with tags
    ${device_1}=  Set device values  device-virtual  Test-Profile-tags
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
