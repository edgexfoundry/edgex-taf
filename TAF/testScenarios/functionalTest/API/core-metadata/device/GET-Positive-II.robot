*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-get-positive-ll.log

*** Test Cases ***
DeviceGET011 - Query all devices with specified device profile by profile name
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Create Device With ${Device}
    When Query All Devices By profileName  Test-Profile-1
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match totalCount
    And Devices Should Be Linked To Specified Device Profile: Test-Profile-1
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET012 - Query all devices with specified device profile by profile name and offset
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Create Device With ${Device}
    And Set Test Variable  ${offset}  1
    When Query All Devices By profileName Test-Profile-1 With offset=${offset}
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match totalCount-offset
    And Devices Should Be Linked To Specified Device Profile: Test-Profile-1
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET013 - Query all devices with specified device profile by profile name and limit
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Create Device With ${Device}
    And Set Test Variable  ${limit}  1
    When Query All Devices By profileName Test-Profile-2 With limit=-1  # all devices with Test-Profile-2
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match limit
    And Devices Should Be Linked To Specified Device Profile: Test-Profile-2
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET014 - Query all devices with specified device service by service name
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  serviceName=${device_service_list}[0]
    And Create Device With ${Device}
    When Query All Devices By serviceName  ${device_service_list}[0]
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match totalCount
    And Devices Should Be Linked To Specified Device Service: ${device_service_list}[0]
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET015 - Query all devices with specified device service by service name and offset
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  serviceName=${device_service_list}[0]
    And Create Device With ${Device}
    And Set Test Variable  ${offset}  2
    When Query All Devices By serviceName ${device_service_list}[0] With offset=${offset}
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match totalCount-offset
    And Devices Should Be Linked To Specified Device Service: ${device_service_list}[0]
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET016 - Query all devices with specified device service by service name and limit
    # number of devices < limit
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Create Device With ${Device}
    And Set Test Variable  ${limit}  2
    When Query All Devices By serviceName ${device_service_list}[1] With limit=${limit}
    Then Should Return Status Code "200" And devices
    And totalCount Is Greater Than Zero And ${content}[devices] Count Should Match limit
    And Devices Should Be Linked To Specified Device Service: ${device_service_list}[1]
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DeviceGET017 - Query device with Chinese naming and query device by name
    Given Set Test Variable  ${test_device_name}  测试中文設備名称
    And Set Test Variable  ${test_profile_name}  测试中文設備資料名称
    And Generate a Device Sample With Associated device-virtual And Chinese Profile Name
    And Set To Dictionary  ${Device}[0][device]  name=${test_device_name}
    And Create Device With ${Device}
    When Query Device By Name  ${test_device_name}
    Then Should Return Status Code "200" and device
    And Should Be True  "${content}[device][name]" == "${test_device_name}"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name ${test_device_name}
    ...                  AND  Delete Device Profile By Name  ${test_profile_name}

*** Keywords ***
Devices Should Be Linked To Specified Device ${associated}: ${associated_name}
    ${devices}=  Set Variable  ${content}[devices]
    ${associated}=  Convert To Lower Case  ${associated}
    FOR  ${item}  IN  @{devices}
        Should Be Equal  ${item}[${associated}Name]  ${associated_name}
    END
