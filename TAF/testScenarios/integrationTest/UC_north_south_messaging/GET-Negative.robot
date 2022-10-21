*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup     Setup Suite
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          North-South Messaging GET Negative Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/north-south-messaging-get-negative.log

*** Test Cases ***
ErrNSMessagingGET001 - Query all DeviceCoreCommands with non-int value on offset
    Given Subscribe MQTT Topic 'edgex/commandquery/response'
    When Query Commands With non-int offset For All Devices From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct

ErrNSMessagingGET002 - Query all DeviceCoreCommands with invalid offset range
    Given Subscribe MQTT Topic 'edgex/commandquery/response'
    When Query Commands With out of range offset For All Devices From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct

ErrNSMessagingGET003 - Query all DeviceCoreCommands with non-int value on limit
    Given Subscribe MQTT Topic 'edgex/commandquery/response'
    When Query Commands With non-int limit For All Devices From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct

ErrNSMessagingGET004 - Query DeviceCoreCommand with non-existent device name
    Given Subscribe MQTT Topic 'edgex/commandquery/response'
    When Query Command With non-existent device From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct

ErrNSMessagingGET005 - Get non-existent device read command
    Given Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command With non-existent device Read Command From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct

ErrNSMessagingGET006 - Get specified device non-existent read command
    Given Create Device For device-virtual
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command With specified device non-existend Read Command From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name

ErrNSMessagingGET007 - Get specified device read command with invalid ds-returnevent
    Given Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command With invalid ds-returnevent From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name

ErrNSMessagingGET008 - Get specified device read command with invalid ds-pushevent
    Given Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command With invalid ds-pushevent From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name

ErrNSMessagingGET009 - Get specified device read command when device AdminState is locked
    Given Create Device For device-virtual
    And Update Device With adminState=LOCKED
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name

ErrNSMessagingGET010 - Get specified device read command when device OperatingState is down
    Given Create Device For device-virtual
    And Update Device With operatingState=DOWN
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name

ErrNSMessagingGET011 - Get unavailable HTTP device read command
    # device-camera
    Given Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command With Camera01 From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct

ErrNSMessagingGET012 - Get unavailable Modbus device read command
    # device-modbus
    Given Create Unavailable Modbus device
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Get Command With Camera01 From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name Test-Device

