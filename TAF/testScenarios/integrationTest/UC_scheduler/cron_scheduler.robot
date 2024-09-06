*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown   Run Teardown Keywords
Force Tags       Skipped

*** Variables ***
${SUITE}         Trigger Cron Scheduler

*** Test Cases ***
CronScheduler001 - Create schedule job with INTERVAL definition and REST action to clean up events and readings
    Given Create A Job With INTERVAL definition To Trigger CleanUp Events And Readings
    And Create Device
    And Create Events And Readings By Get Device Command
    When Wait For Running Schedule Job
    And Query All Events
    Then No Events Should Be Found
    [Teardown]  run keywords  Delete Device By Name
    ...                  AND  Delete Jobs

CronScheduler002 - Create schedule job with INTERVAL definition and DEVICECONTROL action to set device command
    Given Create A Job With INTERVAL definition To Set Device Command
    And Create Device
    When Wait For Running Schedule Job
    And Get Device Command
    Then Device Command Value Should Be The Same With Set Command
    [Teardown]  run keywords  Delete Device By Name
    ...                  AND  Delete Jobs

CronScheduler003 - Create schedule job with CRON definition to send message to app-service
    # Set Topic to external-request which is received by app-external-mqtt-trigger service
    # Subscribe Topic "edgex-export" which is exported from app-external-mqtt-trigger
    Given Subscribe MQTT Broker Topic "edgex-export"
    And Create A Job With CRON definition To Send Message To app-service
    When Wait For Running Schedule Job
    And Message Is Received FROM edgex-export Topic
