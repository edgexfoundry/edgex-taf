*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      v2-api
*** Variables ***
${SUITE}          Core Metadata Device Profile POST Deviceresource Negative Test Cases

*** Test Cases ***
ErrProfileResourcePOST001 - Add deviceResource with Non-existent device profile name
    # non-existent profile name
    Given Generate deviceResource
    And Set To Dictionary  ${resourceProfile}[0]  profileName=non-existent
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileResourcePOST002 - Add deviceResource with Empty profile name
    # empty profile name
    Given Generate deviceResource
    And Set To Dictionary  ${resourceProfile}[0]  profileName=${EMPTY}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileResourcePOST003 - Add deviceResource with duplicate Resource name
    # 2 deviceResource with same resource name
    Given Generate a device profile and Add multiple Resources on device profile
    And Create New resource ${resourceProfile}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST004 - Add deviceResource with Empty Resource Name
    # deviceResources > deviceResource without name
    # Contains valid profile body
    Given Generate a device profile and Add multiple Resources on device profile
    And Set To Dictionary  ${resourceProfile}[0][resource]  name=${EMPTY}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST005 - Add deviceResource with Empty valueType
    # deviceResources > ResourceProperties without valueType
    # Contains valid profile body
    Given Generate a device profile and Add multiple Resources on device profile
    And Set To Dictionary  ${resourceProfile}[0][resource][properties]  valueType=${Empty}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST006 - Add deviceResource with valueType validation error
    # deviceResources > deviceResource invalid valueType
    # Contains valid profile body
    Given Generate a device profile and Add multiple Resources on device profile
    And Set To Dictionary  ${resourceProfile}[0][resource][properties]  valueType=invalid
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST007 - Add deviceResource with Empty readWrite
    # deviceResources > ResourceProperties without readWrite
    # Contains valid profile body
    Given Generate a device profile and Add multiple Resources on device profile
    And Set To Dictionary  ${resourceProfile}[0][resource][properties]  readWrite=${Empty}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST008 - Add deviceResource with readWrite validation error
    # deviceResources > ResourceProperties invalid readWrite
    # Contains valid profile body
    Given Generate a device profile and Add multiple Resources on device profile
    And Set To Dictionary  ${resourceProfile}[0][resource][properties]  readWrite=invalid
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

*** Keywords ***
Generate deviceResource
    ${resource_data}=  Get File  ${WORK_DIR}/TAF/testData/core-metadata/resource_profile.json  encoding=UTF-8
    ${json_string}=  Evaluate  json.loads(r'''${resource_data}''')  json
    Generate resource  ${json_string}
