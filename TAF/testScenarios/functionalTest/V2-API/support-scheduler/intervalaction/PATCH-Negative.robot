*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Scheduler Intervalaction PATCH Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-patch-negative.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
ErrIntervalactionPATCH001 - Update intervalaction with empty name
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH002 - Update intervalaction with invalid name
    Given Create Interval And Intervalaction
    When Update Intervalaction With Invalid Name Format
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH003 - Update intervalaction with empty intervalName
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty intervalName
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH004 - Update intervalaction with not existed intervalName
    Given Create Interval And Intervalaction
    When Update Intervalaction With Not Existed IntervalName
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH005 - Update intervalaction with empty address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH006 - Update intervalaction with empty address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH007 - Update intervalaction with not supported type for address
    # Scheduler only supports REST and MQTT
    Given Create Interval And Intervalaction
    When Update Intervalaction With Not Supported Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH008 - Update intervalaction with empty Host for MQTT Address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Host For MQTT Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH009 - Update intervalaction with empty Port for MQTT Address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Port For MQTT Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH010 - Update intervalaction with empty Publisher for MQTT Address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Publisher For MQTT Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH011 - Update intervalaction with empty Topic for MQTT Address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Topic For MQTT Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH012 - Update intervalaction with empty Host for REST Address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Host For REST Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH013 - Update intervalaction with empty Port for REST Address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty Port For REST Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPATCH014 - Update intervalaction with empty httpMethod for REST Address
    Given Create Interval And Intervalaction
    When Update Intervalaction With Empty httpMethod For REST Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    [Teardown]  Delete IntervalAction And Intervals

