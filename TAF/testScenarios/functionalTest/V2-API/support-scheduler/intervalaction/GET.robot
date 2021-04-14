*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Support Scheduler Intervalaction GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-get.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalactionGET001 - Query all Intervalactions that are less than 20
    Given Create Multiple Intervalactions That Less Than 20
    When Query All Intervalactions
    Then Should Return Status Code "200" And Intervalactions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Created Intervalactions Should Be Found
    [Teardown]  Delete IntervalAction And Intervals

IntervalactionGET002 - Query all Intervalactions that are more than 20
    Given Create Multiple Intervalactions That More Than 20
    When Query All Intervalactions
    Then Should Return Status Code "200" And Intervalactions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Found 20 Intervalactions
    [Teardown]  Delete IntervalAction And Intervals

IntervalactionGET003 - Query all Intervalactions by offset
    Given Create 3 Intervalactions
    When Query All Intervalactions With offset=1
    Then Should Return Status Code "200" And Intervalactions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[Intervalactions]) == 2
    [Teardown]  Delete IntervalAction And Intervals

IntervalactionGET004 - Query all Intervalactions by limit
    Given Create 3 Intervalactions
    When Query All Intervalactions With limit=2
    Then Should Return Status Code "200" And Intervalactions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be True  len(${content}[Intervalactions]) == 2
    [Teardown]  Delete IntervalAction And Intervals

IntervalactionGET005 - Query all Intervalactions by limit = -1
    Given Create Multiple Intervalactions That More Than 20
    When Query All Intervalactions With limit=-1
    Then Should Return Status Code "200" And Intervalactions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And All Created Intervalactions Should Be Found
    [Teardown]  Delete IntervalAction And Intervals

IntervalactionGET006 - Query all Intervalactions by limit = -1 and MaxResultCount= 5
    Given Set MaxResultCount= 5 For Support-Scheduler On Consul
    And Restart Support-Scheduler
    And Create Multiple Intervalactions That More Than 5
    When Query All Intervalactions With limit=-1
    Then Should Return Status Code "200" And Intervalactions
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only 5 Intervalaction Should Be Found
    [Teardown]  Delete IntervalAction And Intervals

IntervalactionGET007 - Query Intervalaction by name
    Given Create Multiple Intervalactions
    When Query Intervalaction By Name
    Then Should Return Status Code "200" And Intervalaction
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only The Intervalaction Should Be Found
    [Teardown]  Delete IntervalAction And Intervals

ErrIntervalactionGET001 - Query Intervalaction by not existed name
    When Query Intervalaction By Not Existed Name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
