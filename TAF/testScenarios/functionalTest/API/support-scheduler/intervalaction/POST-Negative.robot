*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Intervalaction POST Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-post-negative.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
ErrIntervalactionPOST001 - Create intervalaction with empty name
    Given Generate 3 Invervals And IntervalActions Sample
    And Set To Dictionary  ${intervalActions}[0][action]  name=${EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalactionPOST002 - Create intervalaction with invalid name
    # name contains space
    Given Generate 3 Invervals And IntervalActions Sample
    And Set To Dictionary  ${intervalActions}[1][action]  name=invalid name
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalactionPOST003 - Create intervalaction with empty intervalName
    Given Generate 3 Invervals And IntervalActions Sample
    And Set To Dictionary  ${intervalActions}[2][action]  intervalName=${EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalactionPOST004 - Create intervalaction with not existed intervalName
    Given Generate 3 Invervals And IntervalActions Sample
    And Set To Dictionary  ${intervalActions}[0][action]  intervalName=non-existed
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "404"
    And Item Index 1,2 Should Contain Status Code "201" And id
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  ${intervalAction_names}[1]  ${intervalAction_names}[2]
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalactionPOST005 - Create intervalaction with empty address
    Given Generate 3 Invervals And IntervalActions Sample
    And Set To Dictionary  ${intervalActions}[0][action]  address=&{EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalactionPOST006 - Create intervalaction with not supported type for address
    # Scheduler only supports REST, MQTT and EMAIL
    Given Generate 3 Invervals And IntervalActions Sample
    And Set To Dictionary  ${intervalActions}[0][action][address]  type=NEW_TYPE
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalactionPOST007 - Create intervalaction with empty Host for MQTT Address
    Given Create An Interval And Generate An Intervalaction Sample  MQTTAddress
    And Set To Dictionary  ${intervalActions}[0][action][address]  host=${EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionPOST008 - Create intervalaction with empty Port for MQTT Address
    Given Create An Interval And Generate An Intervalaction Sample  MQTTAddress
    And Set To Dictionary  ${intervalActions}[0][action][address]  port=${0}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionPOST009 - Create intervalaction with empty Publisher for MQTT Address
    Given Create An Interval And Generate An Intervalaction Sample  MQTTAddress
    And Set To Dictionary  ${intervalActions}[0][action][address]  publisher=${EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionPOST010 - Create intervalaction with empty Topic for MQTT Address
    Given Create An Interval And Generate An Intervalaction Sample  MQTTAddress
    And Set To Dictionary  ${intervalActions}[0][action][address]  topic=${EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionPOST011 - Create intervalaction with empty Host for REST Address
    Given Create An Interval And Generate An Intervalaction Sample
    And Set To Dictionary  ${intervalActions}[0][action][address]  host=${EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionPOST012 - Create intervalaction with empty Port for REST Address
    Given Create An Interval And Generate An Intervalaction Sample
    And Set To Dictionary  ${intervalActions}[0][action][address]  port=${0}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionPOST013 - Create intervalaction with empty httpMethod for REST Address
    Given Create An Interval And Generate An Intervalaction Sample
    And Set To Dictionary  ${intervalActions}[0][action][address]  httpMethod=${EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionPOST014 - Create intervalaction with empty recipients for EMAIL Address
    Given Create An Interval And Generate An Intervalaction Sample  EmailAddress
    And Set To Dictionary  ${intervalActions}[0][action][address]  recipients=@{EMPTY}
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    [Teardown]  Delete interval by name ${Interval_name}

ErrIntervalactionPOST015 - Create intervalaction with invalid adminState
    Given Create An Interval And Generate An Intervalaction Sample  EmailAddress
    And Set To Dictionary  ${intervalActions}[0][action]  adminState=Invalid
    When Create Intervalaction  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    [Teardown]  Delete interval by name ${Interval_name}
