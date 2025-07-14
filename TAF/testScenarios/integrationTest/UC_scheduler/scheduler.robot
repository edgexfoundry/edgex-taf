*** Settings ***
Resource        TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource        TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource        TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource        TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup     Run keywords   Setup Suite
                ...      AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
                ...      AND  Delete all events by age
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}         Trigger Scheduler

*** Test Cases ***
Scheduler001 - Create schedule job with INTERVAL definition and REST action to clean up events and readings
    ${job}  General A Job Sample  INTERVAL  3s  REST
            ...                   http://edgex-core-data:59880/api/${API_VERSION}/event/age/0  DELETE
    Given Create Device For device-virtual With Name interval-rest-test
    And Generate Multiple Job  ${job}
    And Create Jobs  ${jobs}
    And Create Events By Get Device Command
    When Sleep  4s  # Waiting For Running Schedule Job
    And Query Device Events After Executing Deletion, And No Event Found
    [Teardown]  Run Keywords  Run Keyword If Test Failed  Dump Logs For Debug
                ...      AND  Delete Device By Name ${device_name}
                ...      AND  Delete Multiple Jobs  @{job_names}

Scheduler002 - Create schedule job with INTERVAL definition and DEVICECONTROL action to set device command
    ${set_value}  Set Variable  ${3333}
    ${command}  Set Variable  ${PREFIX}_GenerateDeviceValue_INT32_RW
    ${device_name}  Set Variable  interval-devicecontrol-test
    ${job}  General A Job Sample  INTERVAL  3s  DEVICECONTROL  ${device_name}  ${command}  {"${PREFIX}_DeviceValue_INT32_RW": ${set_value}}
    Given Create Device For device-virtual With Name ${device_name}
    And Generate Multiple Job  ${job}
    And Create Jobs  ${jobs}
    When Sleep  4s  # Waiting For Running Schedule Job
    Then Device Command ${command} Value Should Be The Same With Set Value ${set_value}
    [Teardown]  Run Keywords  Run Keyword If Test Failed  Dump Logs For Debug
                ...      AND  Delete Device By Name ${device_name}
                ...      AND  Delete Multiple Jobs  @{job_names}

Scheduler003 - Create schedule job with CRON definition to send message to app-service
    [Setup]  Start app-mqtt-export Service
    Given Create Device For device-virtual With Name cron-test
    And Generate Job With Event Payload
    And Set Test Variable  ${topic}  edgex-events
    And Start process  python ${WORK_DIR}/TAF/utils/src/setup/mqtt-subscriber.py ${topic} deviceName ${EX_BROKER_PORT} false 1 30 &  # Process for MQTT Subscriber
        ...            shell=True  stdout=${WORK_DIR}/TAF/testArtifacts/logs/${topic}.log
    And Sleep  1s  # Waiting for subscriber is ready
    And Generate Multiple Job  ${job}
    And Create Jobs  ${jobs}
    When Sleep  3s
    And Message Is Received By ${topic} Topic
    [Teardown]  Run Keywords  Run Keyword If Test Failed  Dump Logs For Debug
                ...      AND  Delete Device By Name ${device_name}
                ...      AND  Delete Multiple Jobs  @{job_names}

*** Keywords ***
Device Command ${command} Value Should Be The Same With Set Value ${value}
    Invoke Get command by device ${device_name} and command ${command}
    Should Be Equal As Integers  ${content}[event][readings][0][value]  ${value}

Message Is Received By ${topic} Topic
    Wait Until Keyword Succeeds  6x  1 sec  File Should Not Be Empty  ${WORK_DIR}/TAF/testArtifacts/logs/${topic}.log
    ${subscribe_msg}  Grep File  ${WORK_DIR}/TAF/testArtifacts/logs/${topic}.log  ${device_name}
    Should Not Be Empty  ${subscribe_msg}

Generate Job With Event Payload
    Set Test Variable  ${command}  Virtual_DeviceValue_INT32_RW
    Invoke Get command with params ds-pushevent=true by device ${device_name} and command ${command}
    ${job}  General A Job Sample  CRON  */2 * * * * *  EDGEXMESSAGEBUS
            ...  edgex/events/device/${SERVICE_NAME}/${PREFIX}-Sample-Profile/${device_name}/${command}  ${EMPTY}
            ...  ${content}
    Set Test Variable  ${job}  ${job}

Start ${service} Service
    ${result}  Run Process  docker ps -a | grep -Ev ${service} | grep Exited  shell=True
    Run Keyword If  ${result.rc} == 0  Restart Services  ${service}

Dump Logs For Debug
    Dump Last 100 lines Log  core-data
    Dump Last 100 lines Log  device-virtual
    Dump Last 100 lines Log  support-scheduler
