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
    And Subscribe MQTT Broker Topics
    When Run process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-publisher.py ${mqtt_trigger_topic} "${publish_msg}"
         ...          shell=True
    And Sleep  1s
    Then Message Is Recevied By ${mqtt_trigger_topic} Topic
    And Message Is Recevied By ${mqtt_export_topic} Topic
    [Teardown]  Terminate All Processes  kill=True


*** Keywords ***
Subscribe MQTT Broker Topics
    ${topics}  Create List  ${mqtt_trigger_topic}  ${mqtt_export_topic}
    FOR  ${topic}  IN  @{topics}
        Start process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-subscriber.py ${topic} ${publish_msg} arg   # Process for MQTT Subscriber
        ...                shell=True  stdout=${WORK_DIR}/TAF/testArtifacts/logs/${topic}.log
    END

Message Is Recevied By ${topic} Topic
    ${subscribe_msg}  Grep File  ${WORK_DIR}/TAF/testArtifacts/logs/${topic}.log  ${publish_msg}
    Should Not Be Empty  ${subscribe_msg}

Store Secret With ${service} To Vault
    Set Test Variable  ${url}  http://${BASE_URL}:${APP_EXTERNAL_MQTT_TRIGGER_PORT}
    Store Secret Data With ${service} Auth
