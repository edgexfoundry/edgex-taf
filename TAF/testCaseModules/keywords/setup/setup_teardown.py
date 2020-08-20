"""
 @copyright Copyright (C) 2019 Intel Corporation
 @copyright Copyright (C) 2019 IOTech Ltd
 @license SPDX-License-Identifier: Apache-2.0

 @file setup_teardown.py

 @brief This is a demo test file. This file includes setup and teardown routines called by robot to setup and teardown
     the test suite.

 @description
     This is a demo test file. This file includes setup and teardown routines called by robot to setup and teardown
     the test suite.

"""

import sys
import logging

from TAF.testCaseModules.keywords.setup import tc_utils
from TUC.data.SettingsInfo import SettingsInfo
from TUC.report.ColorLog import ColorLog

__VERSION__ = '1.0'
__SECTION_NAME__ = 'Suite'

"""
   Local utility routines are at the bottom of this file.
   These are routines which are used only by the testcase
   routines in this file.  Also, they are not directly called
   by robot.
"""


def suite_setup(suite_name, logfile, loglevel="DEBUG"):

    """
    Suite_Setup sets up the test cases

    Gets the log and config and puts them in the SettingsInfo object

    The API between Robot and this script is that this script
    return True or False.  The policy here is catch exceptions,
    log them, and return False to Robot.

    @param suite_name:   required suite name
    @param logfile:   required logfile
    @param cfgfile:   required configuration file
    @param loglevel:  sets loglevel
    @retval    True returned to if all code was executed successfully.
    """
    tc_name = "Suite Setup:"

    # Setup logger
    logging.getLogger().setLevel(loglevel)
    test_log = ColorLog(filename=logfile, lvl=loglevel, logName=suite_name, useBackGroundLogger=False)

    loglvl = logging.getLogger().getEffectiveLevel()
    tc_utils.print_log_header(test_log)
    test_log.info('{} Logging started, level: {}'.format(tc_name, logging.getLevelName(loglvl)))
    test_log.info('{} python version: {}'.format(tc_name, sys.version))
    test_log.info('{} testcases version: {}'.format(tc_name, __VERSION__))
    # test_log.info('{} Testcase configuration set from {}'.format(tc_name, cfgfile))
    SettingsInfo().add_name('TestLog', test_log)
    return True


def suite_teardown():
    """
    Teardown the suite:
        print footer
        close the log file

    @retval True returned to robot
    """
    testLog = SettingsInfo().TestLog
    testLog.info("Suite teardown")

    tc_utils.print_log_footer(testLog)
    testLog.close()

    return True
