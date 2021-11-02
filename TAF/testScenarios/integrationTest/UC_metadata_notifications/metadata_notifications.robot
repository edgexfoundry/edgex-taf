*** Settings ***
Resource         TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource         TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource         TAF/testCaseModules/keywords/support-notifications/subscriptionAPI.robot
Resource         TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Resource         TAF/testCaseModules/keywords/support-notifications/transmissionAPI.robot
Resource         TAF/testCaseModules/keywords/device-sdk/deviceServiceAPI.robot
Suite Setup      Run keywords   Setup Suite
...                             AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
...                             AND  Create A subscription To Subscribe Metadata Updates
...                             AND  Set Core-Metadata PostDeviceChanges=true
Suite Teardown   Run keywords   Delete metadata subscription, notifications and transmissions
...                             AND  Run Teardown Keywords
Force Tags       MessageQueue=redis

*** Variables ***
${SUITE}              Send Notifications From Core-Metadata
${LOG_FILE_PATH}      ${WORK_DIR}/TAF/testArtifacts/logs/metadata_notifications.log
${subscriptionName}   Metadata-Subscriber
${subscriptionLabel}  metadata

*** Test Cases ***
Notification001-Send notifications when device is created
    ${start}=  Get current milliseconds epoch time
    Set Test Variable  ${start}  ${start}
    When Create Device For device-virtual With Name metadata-notifications-1
    Then Item Index All Should Contain Status Code "201" And id
    And Notification Should Be Created And Content Contains ${device_name} Device creation
    And Transmission Status Should Be SENT And HTTP Server Received Notification
    [Teardown]  Delete device by name ${device_name}

Notification002-Send notifications when device is updated
    Given Create Device For device-virtual With Name metadata-notifications-2
    ${start}=  Get current milliseconds epoch time
    Set Test Variable  ${start}  ${start}
    When Update Device
    Then Item Index All Should Contain Status Code "200"
    And Notification Should Be Created And Content Contains ${device_name} Device update
    And Transmission Status Should Be SENT And HTTP Server Received Notification
    [Teardown]  Delete device by name ${device_name}

Notification003-Send notifications when device is deleted
    Given Create Device For device-virtual With Name metadata-notifications-3
    ${start}=  Get current milliseconds epoch time
    Set Test Variable  ${start}  ${start}
    When Delete device by name ${device_name}
    Then Should Return Status Code "200"
    And Notification Should Be Created And Content Contains ${device_name} Device removal
    And Transmission Status Should Be SENT And HTTP Server Received Notification

Notification004- Not to Send notifications when core-metadata PostDeviceChanges=false
    Given Set Core-Metadata PostDeviceChanges=false
    ${start}=  Get current milliseconds epoch time
    Set Test Variable  ${start}  ${start}
    When Create Device For device-virtual With Name metadata-notifications-4
    And Item Index All Should Contain Status Code "201" And id
    And Notification Should Not Be Created
    [Teardown]  Run Keywords  Delete device by name ${device_name}
    ...                  AND  Set Core-Metadata PostDeviceChanges=true

*** Keywords ***
Create A subscription To Subscribe Metadata Updates
    Delete Notifications By Age  # delete pre-created device notifications
    Start process  python ${WORK_DIR}/TAF/utils/src/setup/httpd_server.py &  shell=True   # Start HTTP Server
    sleep  1s  # wait for http server startup
    ${labels}=  Create List  ${subscriptionLabel}
    ${channels}=  Load data file "support-notifications/channels_data.json" and get variable "REST"
    Set To Dictionary  ${channels}[0]  host=${DOCKER_HOST_IP}
    ${data}=  Create Dictionary  name=${subscriptionName}  labels=${labels}  channels=${channels}  receiver=${subscriptionName}
    ...       AdminState=UNLOCKED
    ${subscription}=  Create Dictionary  subscription=${data}  apiVersion=${API_VERSION}
    ${subscription_list}=  Create List  ${subscription}
    Create Subscription ${subscription_list}

Delete metadata subscription, notifications and transmissions
    Delete Notifications By Age
    Delete Subscription By Name ${subscriptionName}

Notification Should Be Created And Content Contains ${msg}
    ${end}=  Get current milliseconds epoch time
    Set Test Variable  ${end}  ${end}
    Query Notifications By Start/End Time  ${start}  ${end}
    Should Be True  len(${content}[notifications]) == 1
    Should Be Equal As Strings  ${content}[notifications][0][sender]  edgex-core-metadata
    Should Contain  ${content}[notifications][0][content]  ${msg}
    Set Test Variable  ${msg}  ${msg}

Transmission Status Should Be SENT And HTTP Server Received Notification
    Query Transmissions By Start/End Time  ${start}  ${end}
    Should Be Equal As Strings  ${content}[transmissions][0][status]  SENT
    ${http_server_received}=  Grep File  ${WORK_DIR}/TAF/testArtifacts/logs/httpd-server.log  ${msg}
    Should Not Be Empty  ${http_server_received}  Didn't receive the notification

Update Device
    ${update_adminstate}=  Create Dictionary  name=${device_name}  adminState=LOCKED
    Generate Devices  ${update_adminstate}
    Update devices ${Device}

Set Core-Metadata PostDeviceChanges=${bool}
    ${path}=  Set Variable  v1/kv/edgex/core/${CONSUL_CONFIG_VERSION}/core-metadata/Notifications/PostDeviceChanges
    Update Service Configuration On Consul  ${path}  ${bool}
    Restart Services  metadata

Notification Should Not Be Created
    ${end}=  Get current milliseconds epoch time
    Set Test Variable  ${end}  ${end}
    Query Notifications By Start/End Time  ${start}  ${end}
    Should Be True  len(${content}[notifications]) == 0
