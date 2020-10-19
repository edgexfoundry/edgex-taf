*** Settings ***
Resource         TAF/testCaseModules/keywords/commonKeywords.robot
Suite Setup      Setup Suite

*** Variables ***
${SUITE}         Core Metadata Device DELETE Test Cases

*** Test Cases ***
DeviceDELETE001 - Delete device by ID
    Given Create A Device
    When Delete Device By ID
    Then Should Return Status Code "200"
    And Device Should Be Deleted
    And Response Time Should Be Less Than "1200"ms

DeviceDELETE002 - Delete device by name
    Given Create A Device
    When Delete Device By Name
    Then Should Return Status Code "200"
    And Device Should Be Deleted
    And Response Time Should Be Less Than "1200"ms

ErrDeviceDELETE001 - Delete device by ID with invalid id format
    # use non uuid format, like d138fccc-f39a4fd0-bd32
    Given Create A Device
    When Delete Device By ID
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDeviceDELETE002 - Delete device by ID with non-existent ID
    When Delete Device By ID
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms

ErrDeviceDELETE003 - Delete device by name with empty value
    When Delete Device By Name
    Then Should Return Status Code "400"
    And Response Time Should Be Less Than "1200"ms

ErrDeviceDELETE004 - Delete device by name with non-existent name
    When Delete Device By Name
    Then Should Return Status Code "404"
    And Response Time Should Be Less Than "1200"ms
