*** Settings ***
Suite Setup     Deploy EdgeX
Suite Teardown  Shutdown EdgeX

*** Test Cases ***
DeviceProfile_TC0001 - Create DeviceProfile and ValueDescriptor
    [Tags]  Skipped
    Given DS is configured to use device profile "${device_profile_name}"
    When DS finishes with initialization
    Then DeviceProfile "${device_profile_name}" should be created in Core Metadata
    And DS should create ValueDescriptors in Core Data according to DeviceProfile "${device_profile_name}"