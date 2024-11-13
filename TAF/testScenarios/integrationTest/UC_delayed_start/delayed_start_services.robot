*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown   Run Teardown Keywords
Force Tags       DelayedStart

*** Variables ***
${SUITE}          Delayed Start Validation
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/delayed_start.log

*** Test Cases ***
DelayedStart001-Trace Delayed Start In Service Log
    @{service_list}  Create List  support-notifications  support-scheduler  device-virtual  device-modbus
    ${keyword}  Set Variable  successfully got token from spiffe-token-provider
    FOR  ${service}  IN  @{service_list}
        ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service} 0
        ...     shell=True  stderr=STDOUT  output_encoding=UTF-8  timeout=10s
        Log  ${logs.stdout}
        ${return_log}  Get Lines Containing String  str(${logs.stdout})  ${keyword}
        Run Keyword And Continue On Failure  Should Not Be Empty  ${return_log}
    END
