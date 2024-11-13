*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Support Scheduler Action Record Get Latest Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-scheduler-action-record-get-latest.log

*** Test Cases ***
SchedulerActionLatestGET001 - Query latest schedule action record of job
    Given Create Jobs For Query Schedule Action Record
    And Sleep  3s  # Wait For Running Schedule Job
    And Set Test Variable  ${job_name}  ${job_names}[0]
    When Query Latest Schedule Action Record By Job Name  ${job_name}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And totalCount Should Be 1
    And Job Name ${job_name} Should Be Correct
    [Teardown]  Delete Multiple Jobs  @{job_names}

SchedulerActionLatestGET002 - Query latest schedule action record with non-existent job
    When Query Latest Schedule Action Record By Job Name  not-existent
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
