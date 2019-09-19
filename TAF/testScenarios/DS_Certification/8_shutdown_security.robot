*** Settings ***
Suite Teardown  Shutdown EdgeX


*** Test Cases ***
### Shutdown
Test Registry to consul
    [Tags]  Skipped
    Given Start EdgeX with Registry DS to consul
    When Shutdown DS
    Then DS should be unregistered to consul

Test API through proxy service
    [Tags]  Skipped
    Given Start EdgeX with proxy service
    When Execute API testcases
    Then Response for APIs should be correct
