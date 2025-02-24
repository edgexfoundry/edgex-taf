*** Settings ***
Library      uuid
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource     TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keywords  Delete all events by age
                ...      AND  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Metadata Device POST Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-post-positive.log

*** Test Cases ***
DevicePOST001 - Create device with same device service
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  serviceName=${device_service_list}[0]
    And Set To Dictionary  ${Device}[2][device]  serviceName=${device_service_list}[0]
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePOST002 - Create device with different device service
    [Tags]  SmokeTest
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePOST003 - Create device with uuid
    # Request body contains uuid
    ${random_uuid}=  Evaluate  str(uuid.uuid4())
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1]  requestId=${random_uuid}
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Be Equal  ${content}[1][requestId]  ${random_uuid}
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePOST004 - Create device with Chinese naming
    Given Set Test Variable  ${test_device_name}  测试中文設備名称
    And Set Test Variable  ${test_profile_name}  测试中文設備資料名称
    And Generate a Device Sample With Associated device-virtual And Chinese Profile Name
    And Set To Dictionary  ${Device}[0][device]  name=${test_device_name}
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete device by name ${test_device_name}
                ...      AND  Delete device profile by name  ${test_profile_name}

DevicePOST005 - Create device with empty profileName
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[1][device]  profileName=${EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePOST006 - Create device with empty protocol
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[2][device]  protocols=&{EMPTY}
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample

DevicePOST007 - Create device with autoEvent retention
    ${retention}  Create Dictionary  maxCap=${100}  minCap=${2}  duration=1h
    Given Create Multiple Profiles And Generate Multiple Devices Sample
    And Set To Dictionary  ${Device}[3][device][autoEvents][0]  retention=${retention}
    When Create Device With ${Device}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "201" And id
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Multiple Devices Sample And Profiles Sample
