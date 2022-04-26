*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags      Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile POST Deviceresource Negative Test Cases

*** Test Cases ***
ErrProfileResourcePOST001 - Add deviceResource with Empty device profile name
    # Empty device profile name
    When Add New Resource With Empty device profile name
    Then Should Return Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileResourcePOST002 - Add deviceResource with Non-existent profile name
    # Non-existent device profile name
    When Add New Resource With Non-existent profile name
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "404"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms

ErrProfileResourcePOST003 - Add deviceResource with duplicate Resource name
    # 2 deviceResource with same resource name
    Given Create A Device Profile Sample
    When Add New Resource With the Same Resource Name
    Then Should Return Status Code "207"
    And Item Index 0 Should Contain Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileResourcePOST004 - Add deviceResource with Empty Resource Name
    # deviceResources > deviceResource without name
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Resource With Empty Resource Name
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileResourcePOST005 - Add deviceResource with Empty valueType
    # deviceResources > ResourceProperties without valueType
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Resource With Empty valueType
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileResourcePOST006 - Add deviceResource with valueType validation error
    # deviceResources > deviceResource invalid valueType
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Resource With invalid valueType
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileResourcePOST007 - Add deviceResource with Empty readWrite
    # deviceResources > ResourceProperties without readWrite
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Resource With Empty readWrite
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

ErrProfileResourcePOST008 - Add deviceResource with readWrite validation error
    # deviceResources > ResourceProperties invalid readWrite
    # Contains valid profile body
    Given Create A Device Profile Sample
    When Add New Resource With invalid readWrite
    Then Should Return Status Code "400"
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
    [Teardown]  Delete Device Profile By Name

