*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Intervalaction PATCH Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-patch-negative.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
ErrIntervalactionPATCH001 - Update intervalaction with empty name
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action]  name=${EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH002 - Update intervalaction with invalid name
    # name contains invalid character @
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action]  name=Invalid@Name
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH003 - Update intervalaction with empty intervalName
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action]  intervalName=${EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH004 - Update intervalaction with not existed intervalName
    Given Generate 3 Invervals And IntervalActions Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action]  intervalName=Non-Existed
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "404"
    And Item Index 1,2 Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

ErrIntervalactionPATCH005 - Update intervalaction with empty address
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action]  address=&{EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH006 - Update intervalaction with not supported type for address
    # Scheduler only supports REST, MQTT and EMAIL
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  type=NEW_TYPE
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH007 - Update intervalaction with empty Host for MQTT Address
    Given Create An Interval And Generate An Intervalaction Sample  MQTTAddress
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  host=${EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH008 - Update intervalaction with empty Port for MQTT Address
    Given Create An Interval And Generate An Intervalaction Sample  MQTTAddress
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  port=${0}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH009 - Update intervalaction with empty Publisher for MQTT Address
    Given Create An Interval And Generate An Intervalaction Sample  MQTTAddress
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  publisher=${EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH010 - Update intervalaction with empty Topic for MQTT Address
    Given Create An Interval And Generate An Intervalaction Sample  MQTTAddress
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  topic=${EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH011 - Update intervalaction with empty Host for REST Address
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  host=${EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH012 - Update intervalaction with empty Port for REST Address
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  port=${0}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH013 - Update intervalaction with empty httpMethod for REST Address
    Given Create An Interval And Generate An Intervalaction Sample
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  httpMethod=${EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH014 - Update intervalaction with empty recipients for EMAIL Address
    Given Create An Interval And Generate An Intervalaction Sample  EmailAddress
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action][address]  recipients=@{EMPTY}
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}

ErrIntervalactionPATCH015 - Update intervalaction with invalid adminState
    Given Create An Interval And Generate An Intervalaction Sample  EmailAddress
    And Create Intervalaction  ${intervalActions}
    And Set To Dictionary  ${intervalActions}[0][action]  adminState=Invalid
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    [Teardown]  Run Keywords  Delete IntervalAction By Name ${intervalAction_name}
    ...         AND  Delete interval by name ${Interval_name}
