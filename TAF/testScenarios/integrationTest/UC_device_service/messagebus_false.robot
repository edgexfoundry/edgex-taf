*** Settings ***
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Update Configuration To Set MessageBus To False From Consul
Suite Teardown  Update Configuration To Set MessageBus To True From Consul
Force Tags  skipped

*** Variables ***
${SUITE}         Device Service Test When MessageBus Set To False


*** Test Cases ***
DeviceService005-Send get command with parameters ds-pushevent=no and ds-returnevent=no when messagebus is disabled
    When Send Get Command With Parameters ds-pushevent=no And ds-returnevent=no
    Then Should Return Status Code "200"
    And No Response Contain
    And Event Is Not Pushed To Core Data
    And Event Should Not Be Received by Redis Subscriber

DeviceService006-Send get command with parameters ds-pushevent=yes and ds-returnevent=no when messagebus is disabled
    When Send Get Command With Parameters ds-pushevent=yes And ds-returnevent=no
    Then Should Return Status Code "200"
    And No Response Contain
    And Event Has Been Pushed To Core Data
    And Event Should Not Be Received by Redis Subscriber

DeviceService007-Send get command with parameters ds-pushevent=no and ds-returnevent=yes when messagebus is disabled
    When Send Get Command With Parameters ds-pushevent=no And ds-returnevent=yes
    Then Should Return Status Code "200" And deviceCoreCommands
    And Event Is Not Pushed To Core Data
    And Event Should Not Be Received by Redis Subscriber

DeviceService008-Send get command with parameters ds-pushevent=yes and ds-returnevent=yes when messagebus is disabled
    When Send Get Command With Parameters ds-pushevent=yes And ds-returnevent=yes
    Then Should Return Status Code "200" And deviceCoreCommands
    And Event Has Been Pushed To Core Data
    And Event Should Not Be Received by Redis Subscriber



