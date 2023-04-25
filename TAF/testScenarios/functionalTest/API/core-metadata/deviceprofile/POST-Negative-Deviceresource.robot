*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
*** Variables ***
${SUITE}          Core Metadata Device Profile POST Deviceresource Negative Test Cases

*** Test Cases ***
ErrProfileResourcePOST001 - Add deviceResource with Non-existent device profile name
    # non-existent profile name
    Given Generate multiple deviceResources
    And Set To Dictionary  ${resourceProfile}[0]  profileName=non-existent
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "207"
    And Item Index All Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileResourcePOST002 - Add deviceResource with Empty profile name
    # empty profile name
    Given Generate multiple deviceResources
    And Set To Dictionary  ${resourceProfile}[0]  profileName=${EMPTY}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileResourcePOST003 - Add deviceResource with duplicate Resource name
    # 2 deviceResource with same resource name
    Given Create A Device Profile And Generate Multiple Resources Entity
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
    Given Create A Device Profile And Generate Multiple Resources Entity
    And Set To Dictionary  ${resourceProfile}[0][resource]  name=${EMPTY}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST005 - Add deviceResource with Empty valueType
    # deviceResources > ResourceProperties without valueType
    # Contains valid profile body
    Given Create A Device Profile And Generate Multiple Resources Entity
    And Set To Dictionary  ${resourceProfile}[0][resource][properties]  valueType=${Empty}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST006 - Add deviceResource with valueType validation error
    # deviceResources > deviceResource invalid valueType
    # Contains valid profile body
    Given Create A Device Profile And Generate Multiple Resources Entity
    And Set To Dictionary  ${resourceProfile}[0][resource][properties]  valueType=invalid
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST007 - Add deviceResource with Empty readWrite
    # deviceResources > ResourceProperties without readWrite
    # Contains valid profile body
    Given Create A Device Profile And Generate Multiple Resources Entity
    And Set To Dictionary  ${resourceProfile}[0][resource][properties]  readWrite=${Empty}
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST008 - Add deviceResource with readWrite validation error
    # deviceResources > ResourceProperties invalid readWrite
    # Contains valid profile body
    Given Create A Device Profile And Generate Multiple Resources Entity
    And Set To Dictionary  ${resourceProfile}[0][resource][properties]  readWrite=invalid
    When Create New resource ${resourceProfile}
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete device profile by name  ${test_profile}

ErrProfileResourcePOST009 - Add deviceResource with invalid units value
    Given Create A Device Profile And Generate Multiple Resources Entity
    And Update Service Configuration On Consul  ${uomValidationPath}  true
    When Create Device Resources Contain invalid Units Value
    Then Should Return Status Code "207"
    And Should Return Content-Type "application/json"
    And Item Index All Should Contain Status Code "400"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    And Resources Should Not Be Added in ${test_profile}
    [Teardown]  Run Keywords  Update Service Configuration On Consul  ${uomValidationPath}  false
    ...                  AND  Delete Device Profile By Name  ${test_profile}

*** Keywords ***
Resources Should Not Be Added in ${profile_name}
    Query device profile by name  ${profile_name}
    ${resource_name_list}  Create List
    FOR  ${resource}  IN  @{content}[profile][deviceResources]
            Append To List  ${resource_name_list}  ${resource}[name]
    END
    # Validate
    FOR  ${INDEX}  IN RANGE  len(${resourceProfile})
        List Should Not Contain Value  ${resource_name_list}  ${resourceProfile}[${INDEX}][resource][name]
    END
