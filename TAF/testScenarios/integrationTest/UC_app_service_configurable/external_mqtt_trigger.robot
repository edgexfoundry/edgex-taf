*** Settings ***
Library          Process
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Suite Setup      Setup Suite
Suite Teardown   Run Teardown Keywords
Force Tags       MessageQueue=redis

*** Variables ***
${SUITE}         External MQTT Trigger
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/external_mqtt_trigger.log

*** Test Cases ***
ExternalTrigger001 - Test external mqtt trigger works
    Given Set Test Variable  ${publish_msg}  Message from mqtt publisher
    And Set Test Variable  ${mqtt_trigger_topic}  external-request
    And Set Test Variable  ${mqtt_export_topic}  edgex-export
    And Subscribe MQTT Broker Topics ${mqtt_trigger_topic} With ${EX_BROKER_PORT}  # Subscribe trigger mqtt broker
    And Subscribe MQTT Broker Topics ${mqtt_export_topic} With ${EX_BROKER_PORT}  # Subscribe export mqtt broker
    When Run process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-publisher.py ${mqtt_trigger_topic} "${publish_msg}" ${EX_BROKER_PORT} false
         ...          shell=True
    Then Message Is Recevied By ${mqtt_trigger_topic} Topic
    And Message Is Recevied By ${mqtt_export_topic} Topic
    [Teardown]  Terminate All Processes  kill=True


*** Keywords ***
Subscribe MQTT Broker Topics ${topic} With ${Port}
    Start process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-subscriber.py ${topic} publisher ${Port} false single   # Process for MQTT Subscriber
        ...                shell=True  stdout=${WORK_DIR}/TAF/testArtifacts/logs/${topic}.log
    Sleep  1s  # Waiting for subscriber is ready

Message Is Recevied By ${topic} Topic
    Wait Until Keyword Succeeds  6x  1 sec  File Should Not Be Empty  ${WORK_DIR}/TAF/testArtifacts/logs/${topic}.log
    ${subscribe_msg}  Grep File  ${WORK_DIR}/TAF/testArtifacts/logs/${topic}.log  ${publish_msg}
    Should Not Be Empty  ${subscribe_msg}
