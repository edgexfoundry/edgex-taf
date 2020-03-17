*** Settings ***
Resource  TAF/testCaseModules/keywords/coreMetadataAPI.robot

*** Variables ***
${SUITE}         Create Notification


*** Keywords ***


*** Test Cases ***
Sub001 - Subcriber receives notification by EMAIL channel when label matched
    Given Create device
    And Create subscription and set label to "${matchedlabel}" with reacheable EMAIL channel
    When Update device "${adminStateLocked}"
    Then Subscriber received notification by email
    And Transmission created with status "SENT"

Sub002 - All subcribers receive notification by EMAIL channel when label matched
    Given Create device
    And Create 3 subscriptions and set label to "${label}" with reacheable EMAIL channel
    When Update device "${adminStateLocked}"
    Then Subscriber received notification by email
    And Transmission created with status "SENT"

Sub003 - Subcriber receives notification by REST channel when label matched
    Given Create device
    And Create subscription and set label to "${label}" with REST channel
    When Update device "${adminStateLocked}"
    Then Subscriber received notification by REST
    And Transmission created with status "ACKNOWLEDGED"

Sub004 - All subcribers receive notification by REST channel when label matched
    Given Create device
    And Create 3 subscriptions and set label to "${label}" with REST channel
    When Update device "${adminStateLocked}"
    Then Subscriber received notification by REST
    And Transmission created with status "ACKNOWLEDGED"

Sub005 - Subcriber receives notification by REST and EMAIL channel when label matched
    Given Create device
    And Create subscription and set label to "${label}" with REST channel
    When Update device "${adminStateLocked}"
    Then Subscriber received notification by REST
    And Transmission created with status "ACKNOWLEDGED"
    And Subscriber received notification by EMAIL
    And Transmission created with status "SENT"

Sub006 - All subcribers receive notification by REST and EMAIL channel when label matched
    Given Create device
    And Create 3 subscriptions and set label to "${label}" with REST channel
    When Update device "${adminStateLocked}"
    Then Subscriber received notification by REST
    And Transmission created with status "ACKNOWLEDGED"
    And Subscriber received notification by EMAIL
    And Transmission created with status "SENT"

SubErr001 - Subcriber doesn't receive notification by EMAIL channel if label doesn't match
    Given Create device
    And Create subscription and set label to "${notMatchedLabel}" with EMAIL channel
    When Update device "${adminStateLocked}"
    Then Subscriber didn't receive notification by email
    And No transmission is created

SubErr002 - All subcribers receive notification by partial reachable EMAIL channel when label matched
    Given Create device
    And Create 3 subscriptions and set label to "${label}" with EMAIL channel
    When Update device "${adminStateLocked}"
    Then Subscriber received notification by email with reachable EMAIL
    And Transmission created with status "SENT"
    And Subscriber received notification by email with unreachable EMAIL
    And Transmission created with status "FAILED"

SubErr003 - Subcriber didn't receive notification by REST channel with invalid url when label matched
    Given Create device
    And Create subscription and set label to "${label}" with REST channel
    When Update device "${adminStateLocked}"
    Then Subscriber received notification by REST
    And Transmission created with status "ACKNOWLEDGED"
    And Subscriber received notification by EMAIL
    And Transmission created with status "SENT"