*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup      Run Keywords  Setup Suite  AND  Deploy App Service
Suite Teardown   Run Keywords  Suite Teardown  And  Remove App Service

*** Variables ***
${SUITE}          App-Service Trigger POST Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-trigger.log

*** Test Cases ***
TriggerPOST001 - Trigger pipeline
    When Trigger Function Pipeline
    Then Should Return Status Code "200"
    And  Should Return Expected Data

ErrTriggerPOST001 - Trigger pipeline fails (Invalid Data)
    When Trigger Function Pipeline With Invalid Data
    Then Should Return Status Code "400"

ErrTriggerPOST002 - Trigger pipeline fails (Unprocessable Entity)
    When Trigger Function Pipeline With Unprocessable Entity
    Then Should Return Status Code "422"
