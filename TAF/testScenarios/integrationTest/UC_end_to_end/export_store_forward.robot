*** Settings ***
Resource         TAF/testCaseModules/keywords/app-service/AppServiceAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown   Run Teardown Keywords
Force Tags  skipped


*** Variables ***
${SUITE}         Store And Forward Capability
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/export_store_and_forward.log

*** Test Cases ***
# PersistOnError=true and StoreAndForward.Enable=true
StoreAndForward001 - Stored data is exported after connecting to http server
    Given Set RetryInterval = 3s, MaxRetryCount=3 For app-http-export On Consul
    And Create Device
    When Get device data by device http-export-device and command ${PREFIX}_GenerateDeviceValue_INT8_RW
    And Sleep  6s  # wait until retry fails
    And Start HTTP Server
    Then HTTP Server Received Exported Data
    And Found Retry Log In app-http-export Logs

StoreAndForward002 - Stored data is cleared after the maximum configured retires
    Given Set RetryInterval = 3s, MaxRetryCount=3 For app-http-export On Consul
    And Create Device For device-virtual With Name http-export-device
    When Get device data by device http-export-device and command ${PREFIX}_GenerateDeviceValue_INT8_RW
    And Sleep  12s  # wait until retry fails
    And Start HTTP Server
    Then HTTP Server Didn't Received Exported Data

StoreAndForward003 - Exporting data didn't retry when Writeable.StoreAndForward.Enabled is false
    Given Set StoreAndForward.Enable=false, RetryInterval = 1s, MaxRetryCount=3 For app-http-export On Consul
    And Create Device For device-virtual With Name http-export-device
    When Get device data by device http-export-device and command ${PREFIX}_GenerateDeviceValue_INT8_RW
    And Sleep  3s
    And Start HTTP Server
    Then HTTP Server Didn't Received Exported Data
    And No Retry Log Found In app-http-export Logs

StoreAndForward004 - Retry loop interval is set by the Writeable.StoreAndForward.RetryInterval config setting
    Given Set RetryInterval = 2s, MaxRetryCount=4 For app-http-export On Consul
    And Create Device
    When Get device data by device http-export-device and command ${PREFIX}_GenerateDeviceValue_INT8_RW
    And Sleep  10s  # wait until retry fails
    Then Found 4 times retry log In app-http-export Logs


StoreAndForward005 - Export retries will resume after application service is restarted
    Given Set RetryInterval = 3s, MaxRetryCount=4 For app-http-export On Consul
    And Create Device For device-virtual With Name http-export-device
    When Get device data by device http-export-device and command ${PREFIX}_GenerateDeviceValue_INT8_RW
    And Sleep  7s  # Wait reties
    And Restart Services  app-http-export
    Then HTTP Exporting retried 2 times After Restarting app-http-export


