*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Resource         TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource         TAF/testCaseModules/keywords/support-scheduler/supportSchedulerAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown   Run Teardown Keywords
Force Tags       DelayedStart

*** Variables ***
${SUITE}         Delayed Start Validation

*** Test Cases ***
DelayedStart001-Trace Delayed Start In Service Log
    @{service_list}  Create List  support-notifications  support-scheduler  device-virtual  device-modbus
    ${keyword}  Set Variable  successfully got token from spiffe-token-provider
    FOR  ${service}  IN  @{service_list}
        ${logs}  Run Process  ${WORK_DIR}/TAF/utils/scripts/${DEPLOY_TYPE}/query-docker-logs.sh ${service} 0
        ...     shell=True  stderr=STDOUT  output_encoding=UTF-8
        Log  ${logs.stdout}
        ${return_log}  Get Lines Containing String  str(${logs.stdout})  ${keyword}
        Run Keyword And Continue On Failure  Should Not Be Empty  ${return_log}
    END
