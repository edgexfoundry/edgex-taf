*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Scheduler Intervalaction GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-get.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalactionGET001 - Query all Intervalactions that are less than 20
    Given Generate 3 Invervals And IntervalActions Sample
    And Create Intervalaction  ${intervalActions}
    When Query All IntervalActions
    Then Should Return Status Code "200" And actions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[actions]) == 4  # Contains pre-created intervalaction
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

IntervalactionGET002 - Query all Intervalactions that are more than 20
    Given Generate 21 Invervals And IntervalActions Sample
    And Create Intervalaction  ${intervalActions}
    When Query All Intervalactions
    Then Should Return Status Code "200" And actions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[actions]) == 20
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

IntervalactionGET003 - Query all Intervalactions by offset
    Given Generate 3 Invervals And IntervalActions Sample
    And Create Intervalaction  ${intervalActions}
    When Query All Intervalactions With offset=1
    Then Should Return Status Code "200" And actions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[actions]) == 3  # Contains pre-created intervalaction
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

IntervalactionGET004 - Query all Intervalactions by limit
    Given Generate 3 Invervals And IntervalActions Sample
    And Create Intervalaction  ${intervalActions}
    When Query All Intervalactions With limit=2
    Then Should Return Status Code "200" And actions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[actions]) == 2
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

IntervalactionGET005 - Query all Intervalactions by limit = -1
    Given Generate 3 Invervals And IntervalActions Sample
    And Create Intervalaction  ${intervalActions}
    When Query All Intervalactions With limit=-1
    Then Should Return Status Code "200" And actions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[actions]) == 4  # Contains pre-created intervalaction
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

IntervalactionGET006 - Query all Intervalactions by limit = -1 and MaxResultCount= 5
    Given Set MaxResultCount=5 For Support-Scheduler On Consul
    And Generate 6 Invervals And IntervalActions Sample
    And Create Intervalaction  ${intervalActions}
    When Query All Intervalactions With limit=-1
    Then Should Return Status Code "200" And actions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[actions]) == 5
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}
    ...         AND  Set MaxResultCount=50000 For Support-Scheduler On Consul

IntervalactionGET007 - Query Intervalaction by name
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    When Query Intervalaction By Name ${intervalAction_name}
    Then Should Return Status Code "200" And action
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Strings  ${intervalAction_name}  ${content}[action][name]
    [Teardown]  Run Keywords  Delete intervalAction by name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionGET001 - Query Intervalaction by not existed name
    When Query Intervalaction By Name Non-Existed
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Set MaxResultCount=${number} For Support-Scheduler On Consul
   ${path}=  Set Variable  /v1/kv/edgex/core/${CONSUL_CONFIG_VERSION}/edgex-support-scheduler/Service/MaxResultCount
   Update Service Configuration On Consul  ${path}  ${number}
   Restart Services  scheduler
