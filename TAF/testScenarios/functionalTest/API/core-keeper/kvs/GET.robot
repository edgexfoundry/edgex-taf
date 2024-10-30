*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}          Core Keeper Key/Value GET Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-keeper-kvs-get.log

*** Test Cases ***
KVsGET001 - Value should be returned when query by configuration name(key)
    Given Set Test Variable  ${path}  testKVsGetService/Writable/key
    And Update Service Configuration  ${path}  value
    When Query Service Configuration  ${path}
    Then Should Return Status Code "200" And response
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Should Be Equal As Strings  ${content}[response][0][key]  edgex/${CONFIG_VERSION}/${path}
    [Teardown]  Delete Service Configuration  ${path}

KVsGET002 - Only service configurations are listed if query by service level
    Given Set Test Variable  ${service}  testKVsGetService
    And Add Multiple Configurations
    When Query Service Configuration  ${service}
    Then Should Return Status Code "200" And response
    And apiVersion Should be ${API_VERSION}
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Only Service Configurations Are Listed
    [Teardown]  Delete Multiple Configurations

ErrKVsGET001 - Should return error when query by invalid configuration name(key)
    When Query Service Configuration  testKVsGetServiceErr/invalidKey
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

*** Keywords ***
Only Service Configurations Are Listed
    ${count}  Get Length  ${content}[response]
    FOR  ${INDEX}  IN RANGE  ${count}
        Should Match Regexp  ${content}[response][${INDEX}][key]  edgex\/${CONFIG_VERSION}\/${service}\/*
        ...                  msg=${content}[response][${INDEX}][key] does not belong to ${service}
    END

Add Multiple Configurations
    ${path}  Set Variable  ${service}/Writable
    ${key_list}  Create List  key1  key2  key3
    ${value_list}  Create List  value1  value2  value3
    FOR  ${key}  ${value}  IN ZIP  ${key_list}  ${value_list}
        Update Service Configuration  ${path}/${key}  ${value}
    END
    Set Test Variable  ${key_list}  ${key_list}
    Set Test Variable  ${path}  ${path}

Delete Multiple Configurations
    FOR  ${key}  IN  @{key_list}
        Delete Service Configuration  ${path}/${key}
    END
