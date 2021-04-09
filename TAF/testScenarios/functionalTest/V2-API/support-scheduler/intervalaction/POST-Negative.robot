*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Scheduler Intervalaction POST Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-post-negative.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
ErrIntervalactionPOST001 - Create intervalaction with empty name
    When Create Intervalaction With Empty Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST002 - Create intervalaction with invalid name
    When Create Intervalaction With Invalid Name Format
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST003 - Create intervalaction with empty intervalName
    Given Generate Intervalaction Samples
    When Create Intervalaction With Empty intervalName
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST004 - Create intervalaction with not existed intervalName
    # Needs to Confirm
    When Create Intervalaction With Not Existed IntervalName
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index 0 Should Contain Status Code "404"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST005 - Create intervalaction with empty address
    Given Create Interval
    When Create Intervalaction With Empty Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST006 - Create intervalaction with empty address
    Given Create Interval
    When Create Intervalaction With Empty Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST007 - Create intervalaction with not supported type for address
    # Scheduler only supports REST and MQTT
    Given Create Interval
    When Create Intervalaction With Not Supported Type
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST008 - Create intervalaction with empty Host for MQTT Address
    Given Create Interval
    When Create Intervalaction With Empty Host For MQTT Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST009 - Create intervalaction with empty Port for MQTT Address
    Given Create Interval
    When Create Intervalaction With Empty Port For MQTT Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST010 - Create intervalaction with empty Publisher for MQTT Address
    Given Create Interval
    When Create Intervalaction With Empty Publisher For MQTT Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST011 - Create intervalaction with empty Topic for MQTT Address
    Given Create Interval
    When Create Intervalaction With Empty Topic For MQTT Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST012 - Create intervalaction with empty Host for REST Address
    Given Create Interval
    When Create Intervalaction With Empty Host For REST Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST013 - Create intervalaction with empty Port for REST Address
    Given Create Interval
    When Create Intervalaction With Empty Port For REST Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionPOST014 - Create intervalaction with empty httpMethod for REST Address
    Given Create Interval
    When Create Intervalaction With Empty httpMethod For REST Address
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    [Teardown]  Delete IntervalAction And Intervals

