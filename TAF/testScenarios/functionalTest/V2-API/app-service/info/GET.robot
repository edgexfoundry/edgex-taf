*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup      Run Keywords  Setup Suite  AND  Deploy App Service
Suite Teardown   Run Keywords  Suite Teardown  And  Remove App Service

*** Variables ***
${SUITE}          App-Service GET Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-get.log

*** Test Cases ***
InfoGET001 - Query ping
    When Query Ping
    Then Should Return Status Code "200" And Timestamp

InfoGET002 - Query version
    When Query Version
    Then Should Return Status Code "200" And Version
    And  Should Return SDK Version

InfoGET003 - Query metrics
    When Query Metrics
    Then Should Return Status Code "200" And Metrics

InfoGET004 - Query config
    When Query Config
    Then Should Return Status Code "200" And Config