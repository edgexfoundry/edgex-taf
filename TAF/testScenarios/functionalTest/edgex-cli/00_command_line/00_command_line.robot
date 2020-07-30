*** Settings ***
Documentation    EdgeX Cli
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Library          TAF/testCaseModules/keywords/edgex_cli/Cli.py
Library          Collections
Suite Setup      Setup Suite
Suite Teardown   Suite Teardown

*** Variables ***
${SUITE}         EdgeX deployment
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/edgex_cli.log

*** Keywords ***
# Setup called once before all test cases.
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Suite Setup

*** Test Cases ***
TC0001 - Profiles List Positive
    ${profiles} =  Get Profiles
    ${expectedProfile1}=  Create Dictionary  Profile ID=1925efb0-d831-430f-ae6b-e28bdf3a54dc   Profile Name=Random-Boolean-Device           Created=6 hours   Modified=6 hours   Manufacturer=IOTech   Model=Device-Virtual-01
    ${expectedProfile2}=  Create Dictionary  Profile ID=ead93e5c-5fb2-4a6f-a81a-e99b9cdccd05   Profile Name=Random-Float-Device             Created=6 hours   Modified=6 hours   Manufacturer=IOTech   Model=Device-Virtual-01
    ${expectedProfile3}=  Create Dictionary  Profile ID=3f36009a-b9b0-48e6-b252-aae7b057386c   Profile Name=Random-Integer-Device           Created=6 hours   Modified=6 hours   Manufacturer=IOTech   Model=Device-Virtual-01
    ${expectedProfile4}=  Create Dictionary  Profile ID=45187ab4-bcd9-4c1b-94a7-1ff1d8615f48   Profile Name=Random-UnsignedInteger-Device   Created=6 hours   Modified=6 hours   Manufacturer=IOTech   Model=Device-Virtual-01
    ${expectedProfiles}=  Create List  ${expectedProfile1}  ${expectedProfile2}  ${expectedProfile3}  ${expectedProfile4}
    ${status} =  Should Be Equal  ${profiles}  ${expectedProfiles}

TC0002 - Profiles List Negative
    ${profiles} =  Get Profiles
    ${expectedProfile1}=  Create Dictionary  Profile ID=1925efb0-d831-430f-ae6b-e28bdf3a54dc   Profile Name=Random-Boolean-Device           Created=6 hours   Modified=6 hours   Manufacturer=IOTech   Model=Device-Virtual-01
    ${expectedProfile2}=  Create Dictionary  Profile ID=ead93e5c-5fb2-4a6f-a81a-e99b9cdccd05   Profile Name=Random-Float-Device             Created=6 hours   Modified=6 hours   Manufacturer=IOTech   Model=Device-Virtual-01
    ${expectedProfile3}=  Create Dictionary  Profile ID=3f36009a-b9b0-48e6-b252-aae7b057386c   Profile Name=Random-Integer-Device           Created=6 hours   Modified=6 hours   Manufacturer=IOTech   Model=Device-Virtual-01
    ${expectedProfile4}=  Create Dictionary  Profile ID=45187ab4-bcd9-4c1b-94a7-1ff1d8615f48   Profile Name=Random-UnsignedInteger-Device   Created=6 hours   Modified=6 hours   Manufacturer=IOTech   Model=Device-Virtual-01
    ${expectedProfiles}=  Create List  ${expectedProfile1}  ${expectedProfile2}
    ${status} =  Should Not Be Equal  ${profiles}  ${expectedProfiles}

