*** Settings ***
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Force Tags  skipped

*** Variables ***
${SUITE}         Device Service Test When MessageBus Set To True


*** Test Cases ***
# No nessecary to update consul, because default setting is MessageBus=true
DeviceService001-Send get command with parameters ds-pushevent=no and ds-returnevent=no when messagebus is enabled
    When Send Get Command With Parameters ds-pushevent=no And ds-returnevent=no
    Then Should Return Status Code "200"
    And No Response Contain
    And Event Is Not Pushed To Core Data
    And Event Should Be Received by Redis Subscriber

DeviceService002-Send get command with parameters ds-pushevent=yes and ds-returnevent=no when messagebus is enabled
    When Send Get Command With Parameters ds-pushevent=yes And ds-returnevent=no
    Then Should Return Status Code "200"
    And No Response Contain
    And Event Has Been Pushed To Core Data
    And Event Should Be Received by Redis Subscriber

DeviceService003-Send get command with parameters ds-pushevent=no and ds-returnevent=yes when messagebus is enabled
    When Send Get Command With Parameters ds-pushevent=no And ds-returnevent=yes
    Then Should Return Status Code "200" And deviceCoreCommands
    And Event Is Not Pushed To Core Data
    And Event Should Be Received by Redis Subscriber

DeviceService004-Send get command with parameters ds-pushevent=yes and ds-returnevent=yes when messagebus is enabled
    When Send Get Command With Parameters ds-pushevent=yes And ds-returnevent=yes
    Then Should Return Status Code "200" And deviceCoreCommands
    And Event Has Been Pushed To Core Data
    And Event Should Be Received by Redis Subscriber



