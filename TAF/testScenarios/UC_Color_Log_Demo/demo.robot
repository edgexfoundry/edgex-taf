#
# Copyright (C) 2019 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

*** Settings ***
Resource         ../../config/common.robot
Library          ${UTIL_DIR}/setup/demo_setup_teardown.py
Library          ${TAF_DIR}/testCaseApps/Demo/Demo.py
Suite Setup      Setup Demo Suite
Suite Teardown   Demo Teardown

*** Variables ***
${SUITE_NAME}             DEMO
${demo_log}           ${TESTLOGDIR}/UC_Color_Log_Demo.log

# Relative path from CWD
${test_data_dir}                    testData


*** Keywords ***
# Setup called once before all test cases.
Setup Demo Suite
   ${status} =  Demo Suite Setup  ${demo_log}  ${PLATCONFIG}
   Should Be True  ${status}  Failed Demo Suite Setup

Teardown Server
  Demo Teardown

# Test Case Setup is called before each testcase,
#  but this is not doing anything right now
Test Case Setup
  ${status} =  Demo Test Case Setup
  Should Be True  ${status}  Failed Demo Test Case Setup

# Test Case Teardown is called after each testcase,
#  but this is not doing anything right now
Test Case Teardown
  ${status} =  Demo Test Case Teardown
  Should Be True  ${status}  Failed Demo Test Case Teardown


*** Test cases ***
TC0001 - Read Config File
  [tags]  common  TC0001
  Init Demo
  ${status} =  Log Username
  Should be True  ${status}  Validate TUC Library for read config files

TC0002 - Test Debug Output
  [tags]  common  TC0002
  ${status} =  Test Debug
  Should be True  ${status}  Validate TUC Library for display different colors when debug is logged

TC0003 - Test Info Output
  [tags]  common  TC0003
  ${status} =  Test Info
  Should be True  ${status}  Validate TUC Library for display different colors when info is logged

TC0004 - Test Warn Output
  [tags]  common  TC0004
  ${status} =  Test Warn
  Should be True  ${status}  Validate TUC Library for display different colors when warn is logged

TC0005 - Test Error Output
  [tags]  common  TC0005
  ${status} =  Test Error
  Should be True  ${status}  Validate TUC Library for display different colors when error is logged

TC0006 - Test Log Exception Output
  [tags]  common  TC0006
  ${status} =  Test Log Exception
  Should be True  ${status}  Validate TUC Library for display different colors when error exception is logged

TC0007 - Test PASS Output
  [tags]  common  TC0007
  ${status} =  Test Pass
  Should be True  ${status}  Validate TUC Library for display different colors when PASS is logged

TC0008 - Test Fail Output
  [tags]  common  TC0008
  ${status} =  Test Fail
  Should be True  ${status}  Validate TUC Library for display different colors when FAIL is logged

TC0009 - Test Heading Output
  [tags]  common  TC0009
  ${status} =  Test Heading
  Should be True  ${status}  Validate TUC Library for display different colors when HEADING is logged

