*** Settings ***
Documentation  profile
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Proxy Token
Suite Teardown  Run Keywords  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}              Profile

*** Test Cases ***
Profile001 - Create events with device-command with tags
#Add tags in device-command, the event will contain tags.
    Given Create a profile with device-command with tags
    And Create A Device with the profile
    When Create Event With device-command
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Contain Tags
    And Reading Should Not Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age
                ...  Delete device by name

Profile002 - Create events with device-resource with tags
#Add tags in device-resource, the reading will contain tags.
    Given Create a profile with device-resource with tags
    And Create A Device with the profile
    When Create Event With device-command
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Not Contain Tags
    And Reading Should Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age
    ...  AND  Delete Device By Name

Profile003 - Create events with both device-command and device-resource with tags
#Add tags in device-command, the event will contain tags.
#Add tags in device-resource, the reading will contain tags.
    Given Create a profile with device-command and device-resource with tags
    And Create A Device with the profile
    When Create Event With device-command
    Then Should Return Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Event Should Contain Tags
    And Reading Should Contain Tags
    [Teardown]  Run Keywords  Delete All Events By Age
    ...  AND  Delete Device By Name
