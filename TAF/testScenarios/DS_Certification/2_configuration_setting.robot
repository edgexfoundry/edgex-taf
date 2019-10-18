*** Settings ***
Suite Setup     Deploy EdgeX
Suite Teardown  Shutdown EdgeX

*** Test Cases ***
ConfigurationSetting_TC0001 - Bootstrap option "--registry" is set to true
    [Tags]  Skipped
    Given Bootstrap option "--registry" is set to "true"
    When DS finishes with initialization
    Then DS configuration settings should be provided by the registry

ConfigurationSetting_TC0002 - Bootstrap option "--registry" is set to false
    [Tags]  Skipped
    Given Bootstrap option "--registry" is set to "false"
    When DS finishes with initialization
    Then DS configuration settings should be provided by profile "${default_profile_name}" under "${default_confdir_path}"

ConfigurationSetting_TC0003 - Bootstrap option "--confdir" is set
    [Tags]  Skipped
    Given Bootstrap option "--confdir" is set to "${confdir_path}"
    And Bootstrap option "--registry" is set to "false"
    When DS finishes with initialization
    Then DS configuration settings should be provided by profile "${default_profile_name}" under "${confdir_path}"

ConfigurationSetting_TC0004 - Bootstrap option "--profile" is set
    [Tags]  Skipped
    Given Bootstrap option "--profile" is set to "${profile_name}"
    And Bootstrap option "--registry" is set to "false"
    When DS finishes with initialization
    Then DS configuration settings should be provided by profile "${profile_name}" under "${default_confdir_path}"

ConfigurationSetting_TC0005 - Monitoring settings changes
    [Tags]  Skipped
    [Template]  Monitoring settings changes
    ${setting_description}
    ${setting_labels}
    ${setting_host}
    ${setting_port}

ConfigurationSetting_TC0006 - Startup settings changes
    [Tags]  Skipped
    [Template]  Startup settings changes
    ${setting_description}
    ${setting_labels}
    ${setting_host}
    ${setting_port}

*** Keywords ***
Monitoring settings changes
    [Arguments]  ${setting}
    Given DS can dynamically apply a changed settings
    When Configuration "${setting}" changes
    Then Corresponding object of "${setting}" should be updated by DS

Startup settings changes
    [Arguments]  ${setting}
    Given DS cannot dynamically apply changed settings
    When Configuration "${setting}" changes
    And Restart DS
    Then Corresponding object of "${setting}" should be updated by DS