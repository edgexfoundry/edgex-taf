*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup     Setup Suite
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          North-South Messaging Set Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/north-south-messaging-set.log

*** Test Cases ***
NSMessagingSET001 - Set specified device write command
    Given Create Device For device-virtual
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Set Command From External MQTT Broker
    Then Should Return Error Code "0"
    And Response With Get Command Should Be Correct
    [Teardown]  Delete device by name

ErrNSMessagingSET001 - Set specified device write command with non-existent device
    Given Subscribe MQTT Topic 'edgex/command/response/#'
    When Set Command With Non-existed Device From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name

ErrNSMessagingSET002 - Set specified device write command with non-existent command
    Given Create Device For device-virtual
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Set Command With Specified Device non-existent command From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name

ErrNSMessagingSET002 - Set specified device write command when device is locked
    Given Create Device For device-virtual
    And Update Device With adminState=LOCKED
    And Subscribe MQTT Topic 'edgex/command/response/#'
    When Set Command From External MQTT Broker
    Then Should Return Error Code "1"
    And RequestID Should Be Correct
    [Teardown]  Delete device by name
