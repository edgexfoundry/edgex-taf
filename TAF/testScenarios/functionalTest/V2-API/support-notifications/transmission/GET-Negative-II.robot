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
# /transmission/id/{id}
ErrTransmissionGET010 - Query transmission with invalid id
    When Query Transmission By invalid Id
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET011 - Query transmission with non-existed id
    When Query Transmission By Non-existed Id
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

# /transmission/start/{start}/end/{end}
ErrTransmissionGET012 - Query transmissions by start/end time fails (Invalid Start)
    When Query Transmissions By Invalid Start And End Time
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET013 - Query transmissions by start/end time fails (Invalid End)
    When Query Transmissions By Start And Invalid End Time
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET014 - Query transmissions by start/end time fails (Start>End)
    When Query Transmissions By Start And End Time
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET015 - Query transmissions by start/end time with invalid offset range
    When Query Transmissions By Start And End Time With Invalid Offset Range
    Then Should Return Status Code "416"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET016 - Query transmissions by start/end time with non-int value on offset
    When  Query Transmissions By Start And End Time With Invalid Offset
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrTransmissionGET017 - Query transmissions by start/end time with non-int value on limit
    When Query Transmissions By Start And End Time With Invalid Limit
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
