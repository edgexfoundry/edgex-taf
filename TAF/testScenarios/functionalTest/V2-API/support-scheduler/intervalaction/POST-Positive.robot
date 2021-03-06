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
