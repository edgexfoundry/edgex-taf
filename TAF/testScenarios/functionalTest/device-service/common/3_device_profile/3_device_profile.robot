*** Settings ***
Resource  TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Resource  TAF/testCaseModules/keywords/core-data/coreDataAPI.robot
Resource  TAF/testCaseModules/keywords/common/commonKeywords.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords

*** Variables ***
${SUITE}              Verify Device Profile

*** Test Cases ***
DeviceProfile_TC0001 - Device profile is imported while starting device service
    [Tags]  SmokeTest
    When Query device profile by name  Sample-Profile
    Then Should Return Status Code "200" And profile
    And Should Return Content-Type "application/json"
    And Response Time Should Be Less Than "${default_response_time_threshold}"ms
