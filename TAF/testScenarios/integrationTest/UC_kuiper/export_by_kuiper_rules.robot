*** Settings ***
Library          BuiltIn
Library          Process
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown   Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}         Export By Kuiper Rules
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/export_by_kuiper_rules.log

*** Test Cases ***
Kuiper001 - Add a new rule and export to MQTT
    Given Create A Stream
    And Create A Rule With MQTT Action To Receive Data
    And Create Device For device-virtual With Name kuiper-mqtt-device
    When Execute Get Command ${command} To Trigger kuiper-mqtt-device
    Then Device Data Has Recevied By MQTT Subscriber
    [Teardown]  Run Keywords  Delete device by name kuiper-mqtt-device
                ...      AND  Delete Rules
                ...      AND  Delete Stream

Kuiper002 - Add a new rule to execute set command
    Given Create A Stream
    And Create Rules With REST Action To Set ${resource} Value ${resource_value}
    And Create Device For device-virtual With Name kuiper-edgex-device
    When Set Device Data By Device kuiper-edgex-device And Command ${command}
    And Execute Get Command ${command} To Trigger kuiper-edgex-device
    Then Get ${resource} data And The Value Is Matched With Rules
    [Teardown]  Run Keywords  Delete device by name kuiper-mqtt-device
                ...      AND  Delete Rules
                ...      AND  Delete Stream
