*** Settings ***
Resource     TAF/testCaseModules/keywords/common/commonKeywords.robot
Resource     TAF/testCaseModules/keywords/core-metadata/coreMetadataAPI.robot
Suite Setup  Run Keywords  Setup Suite
...                        AND  Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Get Token
Suite Teardown  Run Teardown Keywords
Force Tags  Skipped

*** Variables ***
${SUITE}          Core Metadata Device Profile PATCH Basicinfo Positive Test Cases
${LOG_FILE_PATH}  ${WORK_DIR}/TAF/testArtifacts/logs/core-metadata-deviceprofile-patch-basicinfo-positive.log

*** Test Cases ***
ProfileBasicInfoPATCH001 - Update one basicinfo of device profile
    #Update one basicinfo on one device profile
    Given Generate and Create Device Profiles Sample For Updating Basicinfo
    And Set To Dictionary  ${deviceProfile}[0][profile]  manufacturer=Mfr_ABC
    When Update device profile ${deviceProfile}
    And Device Profile Basicinfo Should Be Updated
    [Teardown]  Delete Device Profile By Name

ProfileBasicInfoPATCH002 - Update basicinfo of multiple device profiles
    #Update one basicinfo on multiple device profile
    Given Generate and Create Device Profiles Sample For Updating Basicinfo
    And Set To Dictionary  ${deviceProfile}[0][profile]   model=Model_ABC
    And Set To Dictionary  ${deviceProfile}[1][profile]   description=Dcp_ABC
    And Set To Dictionary  ${deviceProfile}[2][profile]   label=Label_ABC
    When Update Basicinfo ${deviceProfile}
    And Device Profile Basicinfo Should Be Updated
    [Teardown]  Delete Device Profile By Name

ProfileBasicInfoPATCH003 - Update multiple basicinfo of device profile
    #Update multiple basicinfo on one device profile
    Given Generate and Create Device Profiles Sample For Updating Basicinfo
    And Set To Dictionary  ${deviceProfile}[0][basicinfo]  manufacturer=Mfr_ABC
    And Set To Dictionary  ${deviceProfile}[0][basicinfo]   model=Model_ABC
    And Set To Dictionary  ${deviceProfile}[0][basicinfo]   description=Dcp_ABC
    And Set To Dictionary  ${deviceProfile}[0][basicinfo]   labels=Label_ABC
    When Update basicinfo ${deviceprofile}
    And Device Profile Basicinfo Should Be Updated
    [Teardown]  Delete Device Profile By Name

