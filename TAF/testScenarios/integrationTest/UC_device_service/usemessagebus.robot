*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource     TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup  Run keywords   Setup Suite
...                   AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Device Service Test When MessageBus Set To True
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/messagebus_true.log


# No nessecary to update registry service, because default setting is MessageBus=true
*** Test Cases ***
DeviceService001-Send get command with parameters ds-pushevent=false and ds-returnevent=false
    Set Test Variable  ${device_name}  messagebus-true-device-1
    ${params}  Create Dictionary  ds-pushevent=false  ds-returnevent=false
    Given Run MQTT Subscriber Progress And Output  edgex/events/device/#
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200"
    And Event Is Not Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by MQTT Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

DeviceService002-Send get command with parameters ds-pushevent=true and ds-returnevent=false
    Set Test Variable  ${device_name}  messagebus-true-device-2
    ${params}  Create Dictionary  ds-pushevent=true  ds-returnevent=false
    Given Run MQTT Subscriber Progress And Output  edgex/events/device/#
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200"
    And Event Has Been Pushed To Core Data
    And Event With Device ${device_name} Should Be Received by MQTT Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

DeviceService003-Send get command with parameters ds-pushevent=false and ds-returnevent=true
    Set Test Variable  ${device_name}  messagebus-true-device-3
    ${params}  Create Dictionary  ds-pushevent=false  ds-returnevent=true
    Given Run MQTT Subscriber Progress And Output  edgex/events/device/#
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event Is Not Pushed To Core Data
    And Event With Device ${device_name} Should Not Be Received by MQTT Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

DeviceService004-Send get command with parameters ds-pushevent=true and ds-returnevent=true
    Set Test Variable  ${device_name}  messagebus-true-device-4
    ${params}  Create Dictionary  ds-pushevent=true  ds-returnevent=true
    Given Run MQTT Subscriber Progress And Output  edgex/events/device/#
    And Create Device For device-virtual With Name ${device_name}
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event Has Been Pushed To Core Data
    And Event With Device ${device_name} Should Be Received by MQTT Subscriber ${subscriber_file}
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True

DeviceService005-Customize BaseTopicPrefix works correctly
    Set Test Variable  ${device_name}  messagebus-true-device-5
    ${params}  Create Dictionary  ds-pushevent=true  ds-returnevent=true
    Given Run MQTT Subscriber Progress And Output  custom/events/device/#
    And Create Device For device-virtual With Name ${device_name}
    And Set BaseTopicPrefix to custom For core-common-config-bootstrapper On Registry Service
    When Get device data by device ${device_name} and command ${PREFIX}_GenerateDeviceValue_INT8_RW with ${params}
    Then Should Return Status Code "200" And event
    And Event With Device ${device_name} Should Be Received by MQTT Subscriber ${subscriber_file}
    And Event Has Been Pushed To Core Data
    [Teardown]  Run keywords  Delete device by name ${device_name}
                ...      AND  Delete all events by age
                ...      AND  Terminate Process  ${handle_mqtt}  kill=True
                ...      AND  Set BaseTopicPrefix to edgex For core-common-config-bootstrapper On Registry Service

*** Keywords ***
Set ${config} to ${value} For core-common-config-bootstrapper On Registry Service
    ${path}=  Set Variable  /core-common-config-bootstrapper/all-services/MessageBus/${config}
    Update Service Configuration  ${path}  ${value}
    FOR  ${service}  IN  device-virtual  core-data
        Restart Services  ${service}
        Run Keyword If  '${service}' == 'device-virtual'  Set Test Variable  ${url}  ${deviceServiceUrl}
        ...    ELSE IF  '${service}' == 'core-data'  Set Test Variable  ${url}  ${coreDataUrl}
        FOR  ${INDEX}  IN RANGE  5
            Query Ping
            Run Keyword If  ${response} == 200  Exit For Loop
            ...       ELSE  Sleep  5s
        END
    END
