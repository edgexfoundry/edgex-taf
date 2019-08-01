#
# Copyright (C) 2019 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

*** Settings ***
Documentation    Test Suite RSP
Library    ${TUC_DIR}/setup/setup_python.py

*** Variables ***
${PLATFORMDIR}      ../..
${TAF_DIR}         ${PLATFORMDIR}
${TUC_DIR}         ${PLATFORMDIR}/edgex-taf-Common/TUC
${UTIL_DIR}         ${TAF_DIR}/utils/src
${LIB_DIR}          ${UTIL_DIR}/lib

## the test case appdir is where the testapp is located
${TESTCASELOGDIR}    ${TAF_DIR}/testArtifacts/logs

## the test config dir is where the test configuration files are located
${PLATCONFIGDIR}           ${TAF_DIR}/config
${PLATCONFIG}              ${PLATCONFIGDIR}/platform.cfg

## TESTLOGDIR - note that ../testArtifacts/logs is part of the code directory structure
${TESTLOGDIR}                 ${TAF_DIR}/testArtifacts/logs
${testcase_cfg}               ${PLATCONFIGDIR}/default.cfg
