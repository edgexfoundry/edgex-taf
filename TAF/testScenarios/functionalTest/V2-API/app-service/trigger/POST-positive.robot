*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup      Run Keywords  Setup Suite  AND  Deploy App Service
Suite Teardown   Run Keywords  Suite Teardown  AND  Remove App Service

*** Variables ***
${SUITE}          App-Service Trigger POST Positive Testcases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/app-service-trigger-positive.log
${edgex_profile}  blackbox-tests

*** Test Cases ***
TriggerPOST001 - Trigger pipeline (no match)
    When Trigger Function Pipeline With No Matching DeviceName
    Then Should Return Status Code "200"
    And  Body Should Match Empty

TriggerPOST002 - Trigger pipeline (XML)
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And  Body Should Match XML String

TriggerPOST003 - Trigger pipeline (JSON)
    Given Set TransformToJSON
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And  Body Should Match JSON String

TriggerPOST004 - Trigger pipeline (JSON-GZIP)
    Given Set CompressWithGZIP
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And  Body Should Match JSON String

TriggerPOST005 - Trigger pipeline (JSON-ZLIB)
    Given Set CompressWithZLIB
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And  Body Should Match JSON String

TriggerPOST006 - Trigger pipeline (JSON-ZLIB-AES)
    Given Set EncryptWithAES
    When Trigger Function Pipeline With Matching DeviceName
    Then Should Return Status Code "200"
    And  Body Should Match JSON String