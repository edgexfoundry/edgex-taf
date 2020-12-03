*** Settings ***
Library    TAF/testCaseModules/keywords/scalabilityTest/modbus/run.py
Library    TAF/testCaseModules/keywords/scalabilityTest/modbus/report.py
Library    TAF/testCaseModules/keywords/common/consul.py
Library    TAF/testCaseModules/keywords/setup/edgex.py
Resource   TAF/testCaseModules/keywords/common/commonKeywords.robot
Variables  TAF/config/modbus_scalability_test/configuration.py

Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                        AND  Deploy EdgeX
...                        AND  Deploy device service  ${SERVICE_NAME}
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token

*** Variables ***
${SUITE}              Modbus scalability testing
${LOG_FILE_PATH}      ${WORK_DIR}/TAF/testArtifacts/logs/modbus_scalability_test.log

*** Test Cases ***
Test Modbus scalability
     Given Modify consul config  /v1/kv/edgex/core/1.0/edgex-core-data/Writable/PersistData  false
     And Deploy services  scalability-test-mqtt-export
     sleep  30
     ${report_info}  ${records} =  When run scalability testing
     Then generate report  ${report_info}  ${records}

