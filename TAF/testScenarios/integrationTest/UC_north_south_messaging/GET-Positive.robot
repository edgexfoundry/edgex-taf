*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup     Setup Suite
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          North-South Messaging GET Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/north-south-messaging-get-positive.log

*** Test Cases ***
NSMessagingGET001 - Query all DeviceCoreCommands
    Given Create 3 Devices For device-virtual
    And Subscribe MQTT Topic 'edgex/commandquery/response'
    When Query Commands For All Devices From External MQTT Broker
    Then Should Return Error Code "0"
    And Commands For All Devices Should Be Returned
    [Teardown]  Delete multiple devices

NSMessagingGET002 - Query all DeviceCoreCommands by offset
    Given Create 3 Devices For device-virtual
    And Subscribe MQTT Topic 'edgex/commandquery/response'
    When Query Commands With Offset For All Devices From External MQTT Broker
    Then Should Return Error Code "0"
    And Commands For All Devices Should Be Returned
    [Teardown]  Delete multiple devices

NSMessagingGET003 - Query all DeviceCoreCommands by limit
    Given Create 3 Devices For device-virtual
    And Subscribe MQTT Topic 'edgex/commandquery/response'
    When Query Commands With Limit For All Devices From External MQTT Broker
    Then Should Return Error Code "0"
    And Commands For All Devices Should Be Returned
    [Teardown]  Delete multiple devices

NSMessagingGET004 - Query DeviceCoreCommand by device name
    Given Create A Device For device-virtual
    And Subscribe MQTT Topic 'edgex/commandquery/response'
    When Query Commands For Specified Device From External MQTT Broker
    Then Should Return Error Code "0"
    And Commands For Specified Devices Should Be Returned
    [Teardown]  Delete Device By Name

NSMessagingGET005 - Get specified device read command
    Given Create Device For device-virtual
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command From External MQTT Broker
    Then Should Return Error Code "0"
    And Response With Get Command Should Be Correct
    [Teardown]  Delete Device By Name

NSMessagingGET006 - Get specified device read command when ds-returnevent is no
    Given Create Device For device-virtual
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command With ds-returnevent=no From External MQTT Broker
    Then Should Return Error Code "0"
    And No Event Found Found In Payload
    [Teardown]  Delete Device By Name

NSMessagingGET007 - Get specified device read command when ds-pushevent is yes
    Given Create Device For device-virtual
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command With ds-pushevent=yes From External MQTT Broker
    Then Should Return Error Code "0"
    And Response With Get Command Should Be Correct
    And Event Has Been Pushed To Core Data
    [Teardown]  Delete Device By Name
