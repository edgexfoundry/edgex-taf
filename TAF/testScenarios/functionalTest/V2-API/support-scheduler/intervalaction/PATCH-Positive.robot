*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  v2-api

*** Variables ***
${SUITE}          Support Scheduler Intervalaction PATCH Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-intervalaction-patch-positive.log
${url}            ${supportSchedulerUrl}

*** Test Cases ***
IntervalactionPATCH001 - Update intervalaction
    Given Create IntervalActions And Generate Multiple IntervalActions Sample For Updating Data
    When Update IntervalActions  ${intervalActions}
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "200"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And IntervalActions Should Be Updated
    [Teardown]  Run Keywords  Delete Multiple IntervalActions By Names  @{intervalAction_names}
    ...         AND  Delete Multiple Intervals By Names  @{Interval_names}

*** Keywords ***
Create IntervalActions And Generate Multiple IntervalActions Sample For Updating Data
    Generate 2 Invervals And IntervalActions Sample
    Create Intervalaction  ${intervalActions}
    ${recipients}=  Create List  new@email.com  test-1@email.com  test-2@email.com
    ${update_address}=  Create Dictionary  name=${intervalActions}[0][action][name]  address=${intervalActions}[0][action][address]
    ${update_interval}=  Create Dictionary  name=${intervalActions}[1][action][name]  intervalName=${intervalActions}[1][action][intervalName]
    Run Keyword If  "${update_address}[address][type]" == "EMAIL"  Set To Dictionary  ${update_address}[address]  recipients=@{recipients}
    ...       ELSE  Set To Dictionary  ${update_address}[address]  port=${1234}
    Set To Dictionary  ${update_interval}  intervalName=${interval_names}[0]
    Set Test Variable  ${new_recipients}  ${recipients}
    Set Test Variable  ${new_interval}  ${update_interval}[intervalName]
    Set Test Variable  ${new_port}  ${1234}
    Generate IntervalActions  ${update_address}  ${update_interval}

IntervalActions Should Be Updated
    Query IntervalAction By Name ${intervalAction_names}[0]
    Run Keyword If  "${content}[action][address][type]" == "EMAIL"  Should Be Equal  ${content}[action][address][recipients]  ${new_recipients}
    ...       ELSE  Should Be Equal  ${content}[action][address][port]  ${new_port}
    Query IntervalAction By Name ${intervalAction_names}[1]
    Should Be Equal  ${content}[action][intervalName]  ${new_interval}

