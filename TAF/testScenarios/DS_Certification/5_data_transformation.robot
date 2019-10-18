*** Settings ***
Suite Setup     Deploy EdgeX and prepare device for data transformation testing
Suite Teardown  Shutdown EdgeX

*** Test Cases ***
DataTransformation_TC0001 - Validate ReadData transformation
    [Tags]  Skipped
    [Template]  Validate ReadData transformation
    ${resource_test_base}     ${attrubute_base}      ${attribute_value_base}      ${expected_result_base}
    ${resource_test_scale}    ${attrubute_scale}     ${attribute_value_scale}     ${expected_result_scale}
    ${resource_test_offset}   ${attrubute_offset}    ${attribute_value_offset}    ${expected_result_offset}
    ${resource_test_mask}     ${attrubute_mask}      ${attribute_value_mask}      ${expected_result_mask}
    ${resource_test_shift}    ${attrubute_shift}     ${attribute_value_shift}     ${expected_result_shift}

DataTransformation_TC0002 - Validate WriteData transformation
    [Tags]  Skipped
    [Template]  Validate WirteData transformation
    ${resource_test_base}      ${attrubute_base}      ${attribute_value_base}      ${original_input_value_base}
    ${resource_test_scale}     ${attrubute_scale}     ${attribute_value_scale}     ${original_input_value_scale}
    ${resource_test_offset}    ${attrubute_offset}    ${attribute_value_offset}    ${original_input_value_offset}

DataTransformation_TC0003 - Overflow error
    [Tags]  Skipped
    Given "${resource_test_overflow}" specify attribute "scale" with value "${value_overflow}"
    When ${response} = Get "${resource_test_overflow}" reading
    Then Status code of "${response}" should be "500"
    And Reading value in "${response}" should be "Overflow failed for device resource: ${resource_test_overflow}"

DataTransformation_TC0004 - Overflow error if the /device/all/{command} endpoint is used
    [Tags]  Skipped
    Given "${resource_test_overflow}" specify attribute "scale" with value "${value_overflow}"
    When ${response} = Issue a /device/all/{command} for "${resource_test_overflow}"
    Then Status code in "${response}" should be "200"

DataTransformation_TC0005 - Assertion
    [Tags]  Skipped
    Given "${resource_test_assertion}" specify attribute "assertion" with value "${value_assertion}"
    When ${response} = Get "${resource_test_assertion}" reading
    Then Status code of "${response}" should be "200"
    And Reading value in "${response}" should be "${expected_value_assertion}"

DataTransformation_TC0006 - Assertion failed
    [Tags]  Skipped
    Given "${resource_test_assertion_failed}" specify attribute "assertion" with value "${value_assertion}"
    When ${response} = Get "${resource_test_assertion_failed}" reading
    Then Status code of "${response}" should be "500"
    And Reading value in "${response}" should be "Assertion failed for device resource: ${resource_test_assertion_failed}"

DataTransformation_TC0007 - Assertion failed if the /device/all/{command} endpoint is used
    [Tags]  Skipped
    Given "${resource_test_assertion_failed}" specify attribute "assertion" with value "${value_assertion}"
    When ${response} = Issue a /device/all/{command} for "${resource_test_assertion_failed}"
    Then Status code in "${response}" should be "200"

DataTransformation_TC0008 - Mapping
    [Tags]  Skipped
    Given "${resource_test_mapping}" specify attribute "mappings" with value "${value_mapping}" in DeviceCommand
    When ${response} = Get "${resource_test_mapping}" reading
    Then Reading value in "${response}" should be "${expected_value_mapping}"

DataTransformation_TC0009 - Mapping failed
    [Tags]  Skipped
    Given "${resource_test_mapping_failed}" specify attribute "mappings" with value "${value_mapping}" in DeviceCommand
    When ${response} = Get "${resource_test_mapping_failed}" reading
    Then Reading value in "${response}" should be "${expected_value_mapping_failed}"

*** Keywords ***
Validate ReadData transformation
    [Arguments]    ${resource}    ${attribute}    ${attribute_value}    ${expected_value}
    Given "${resource}" specify "${attribute}" with value "${attribute_value}" in PropertyValues
    When ${response} = Get "${resource}" reading
    Then Reading value in "${response}" should be "${expected_value}"

Validate WirteData transformation
    [Arguments]    ${resource}    ${attribute}    ${attribute_value}    ${original_input_value}
    Given "${resource}" specify "${attribute}" with value "${attribute_value}" in PropertyValues
    When Put value "${original_input_value}" to "${resource}"
    And ${response} = Get "${resource}" reading
    Then Reading value in "${response}" should be "${original_input_value}"