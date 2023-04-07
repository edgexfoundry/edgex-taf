*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Scheduler Intervalaction POST Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-post-positive.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalactionPOST001 - Create intervalaction
    Given Generate 3 Invervals And IntervalActions Sample
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

IntervalactionPOST002 - Create pre-created intervalaction with pre-created interval
    # inteval < ScheduleIntervalTime
    Given Set support-scheduler configs ScheduleIntervalTime=1000 And LogLevel=DEBUG
    When Create Pre-Created HalfSecond Interval And PingScheduler Intervalaction By Configs
    Then Pre-Created Interval And IntervalAction Should Be Created
    And Wait Until Keyword Succeeds  2x  1s  IntervalAction Should Be Executed Every ScheduleIntervalTime
    [Teardown]  Run Keywords  Set support-scheduler configs ScheduleIntervalTime=500 And LogLevel=INFO
    ...   AND   Delete Pre-Created HalfSecond Interval And PingScheduler IntervalAction

*** Keywords ***
Set support-scheduler configs ScheduleIntervalTime=${millisecond} And LogLevel=${logLevel}
    Set Test Variable  ${consul_path}    ${CONSUL_CONFIG_BASE_ENDPOINT}/support-scheduler
    Update Service Configuration On Consul  ${consul_path}/Writable/LogLevel  ${logLevel}
    Update Service Configuration On Consul  ${consul_path}/ScheduleIntervalTime  ${millisecond}

Create Pre-Created HalfSecond Interval And PingScheduler Intervalaction By Configs
    Set Test Variable  ${interval_name}  HalfSecond
    Set Test Variable  ${intervalAction_name}  PingScheduler
    ${interval}=  Create Dictionary  Name=${interval_name}  Interval=500ms  Start=20200101T000000
    ${intervalAction}=  Create Dictionary  Name=${intervalAction_name}  Interval=${interval_name}  Method=GET  Port=59861
    ...                 Host=edgex-support-scheduler  Path=/api/${API_VERSION}/ping  AdminState=UNLOCKED
    FOR  ${kv}  IN  &{interval}
        Update Service Configuration On Consul  ${consul_path}/Intervals/${interval_name}/${kv}[0]  ${kv}[1]
    END
    FOR  ${kv}  IN  &{intervalAction}
      Update Service Configuration On Consul  ${consul_path}/IntervalActions/${intervalAction_name}/${kv}[0]  ${kv}[1]
    END
    ${timestamp}=  Get current epoch time
    Set Test Variable  ${timestamp}  ${timestamp}
    Restart Services  support-scheduler
    Wait Until Keyword Succeeds  10x  1s  Ping Scheduler Service

Delete Pre-Created HalfSecond Interval And PingScheduler IntervalAction
    Delete intervalAction by name ${intervalAction_name}
    Delete interval by name ${interval_name}
    ${consul_token}  Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Get Consul Token
    ${headers}=  Create Dictionary  X-Consul-Token=${consul_token}
    ${url}  Set Variable  http://${BASE_URL}:${REGISTRY_PORT}
    Create Session  Consul  url=${url}  disable_warnings=true
    DELETE On Session  Consul  ${consul_path}/IntervalActions/${intervalAction_name}  params=recurse=true  headers=${headers}
    ...  expected_status=200
    DELETE On Session  Consul  ${consul_path}/Intervals/${interval_name}  params=recurse=true  headers=${headers}
    ...  expected_status=200
    Restart Services  support-scheduler

Pre-Created Interval And IntervalAction Should Be Created
    Query Interval By Name ${interval_name}
    Should Return Status Code "200"
    Query IntervalAction By Name ${intervalAction_name}
    Should Return Status Code "200"

IntervalAction Should Be Executed Every ScheduleIntervalTime
    ${keyword}=  Set Variable  1 action need to be executed with interval ${interval_name}
    ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh support-scheduler ${timestamp}
    ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
    ${return_log}=  Get Lines Containing String  str(${logs.stdout})  ${keyword}
    ${times}=  Get Regexp Matches  ${return_log}  :([0-5][0-9]:[0-5][0-9].[0-9]+)  1
    ${time_diff}=  Subtract Time From Time  ${times}[1]  ${times}[0]
    Should Be True  int(round(0.9981947000001128)) == 1

Ping Scheduler Service
    Query Ping
    Should return status code "200"
