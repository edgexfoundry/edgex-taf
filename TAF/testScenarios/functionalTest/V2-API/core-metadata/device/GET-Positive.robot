*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token
Default Tags    v2-api

*** Variables ***
${SUITE}          Core Metadata Device GET Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-device-get-positive.log
${api_version}    v2

*** Test Cases ***
DeviceGET001 - Query all devices
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-1
    And Create Device With ${Device}
    When Query All Devices
    Then Should Return Status Code "200" And devices
    And Should Be True  len(${content}[devices]) == 4
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names
    ...                       Test-Device  Test-Device-Locked  Test-Device-Disabled  Test-Device-AutoEvents
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

DeviceGET002 - Query all devices with offset
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-2
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-2
    And Create Device With ${Device}
    When Query All Devices With offset=2
    Then Should Return Status Code "200" And devices
    And Should Be True  len(${content}[devices]) == 2
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names
    ...                       Test-Device  Test-Device-Locked  Test-Device-Disabled  Test-Device-AutoEvents
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

DeviceGET003 - Query all devices with limit
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-3
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-3
    And Create Device With ${Device}
    When Query All Devices With limit=3
    Then Should Return Status Code "200" And devices
    And Should Be True  len(${content}[devices]) == 3
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names
    ...                       Test-Device  Test-Device-Locked  Test-Device-Disabled  Test-Device-AutoEvents
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-3

DeviceGET004 - Query all devices with specified labels
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-4
    And Create Device Profile ${deviceProfile}
    And Generate Multiple Devices Sample  Test-Device-Service  Test-Profile-4
    And Set To Dictionary  ${Device}[1][device]  labels=@{EMPTY}
    And Append To List  ${Device}[2][device][labels]  new_label
    And Create Device With ${Device}
    When Query All Devices With labels=device-example
    Then Should Return Status Code "200" And devices
    And Should Be True  len(${content}[devices]) == 3
    And Devices Should Be Linked To Specified Label: device-example
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Multiple Devices By Names
    ...                       Test-Device  Test-Device-Locked  Test-Device-Disabled  Test-Device-AutoEvents
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-4

DeviceGET005 - Query device by name
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-1
    And Create Device Profile ${deviceProfile}
    And Generate A Device Sample  Test-Device-Service  Test-Profile-1
    And Create Device With ${Device}
    When Query Device By Name  Test-Device
    Then Should Return Status Code "200" and device
    And Should Be True  "${content}[device][name]" == "Test-Device"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-1

DeviceGET006 - Check device exists by name
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-2
    And Create Device Profile ${deviceProfile}
    And Generate A Device Sample  Test-Device-Service  Test-Profile-2
    And Create Device With ${Device}
    When Check Existence Of Device By Name  Test-Device
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-2

DeviceGET006 - Check device exists by id
    Given Generate A Device Service Sample
    And Create Device Service ${deviceService}
    And Generate A Device Profile Sample  Test-Profile-3
    And Create Device Profile ${deviceProfile}
    And Generate A Device Sample  Test-Device-Service  Test-Profile-3
    And Create Device With ${Device}
    And Get "id" From Multi-status Item 0
    When Check Existence Of Device By Id  ${item_value}
    Then Should Return Status Code "200"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Run Keywords  Delete Device By Name Test-Device
    ...                  AND  Delete Device Service By Name  Test-Device-Service
    ...                  AND  Delete Device Profile By Name  Test-Profile-3

*** Keywords ***
Devices Should Be Linked To Specified Label: ${label}
    ${devices}=  Set Variable  ${content}[devices]
    FOR  ${item}  IN  @{devices}
        List Should Contain Value  ${item}[labels]  ${label}
    END
