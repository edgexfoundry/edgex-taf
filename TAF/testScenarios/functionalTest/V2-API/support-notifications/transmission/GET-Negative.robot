*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/support-notifications/notificationAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  skipped

*** Variables ***
${SUITE}          Support Notifications Transmission GET Negative Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/support-notifications-transmission-get-negative.log
${url}            ${supportNotificationsUrl}

*** Test Cases ***
# /transmission/all
ErrTransmissionGET001 - Query all transmissions by status with invalid offset range
    When Query All Transmissions By Status With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET002 - Query all transmissions by status with non-int value on offset
    When Query All Transmissions By Status With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET003 - Query all transmissions by status with non-int value on limit
    When Query All Transmissions By Status With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /transmission/status/{status}
ErrTransmissionGET004 - Query transmissions by status with invalid offset range
    When Query Transmissions By Status With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET005 - Query transmissions by status with non-int value on offset
    When Query Transmissions By Status With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET006 - Query transmissions by status with non-int value on limit
    When Query Transmissions By Status With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /transmission/subscription/name/{name}
ErrTransmissionGET007 - Query transmissions by subscription with invalid offset range
    When Query Transmissions By Subscription With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET008 - Query transmissions by subscription with non-int value on offset
    When Query Transmissions By Subscription With offset=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET009 - Query transmissions by subscription with non-int value on limit
    When Query Transmissions By Subscription With limit=invalid
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
