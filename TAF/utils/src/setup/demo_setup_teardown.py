"""
 @copyright Copyright (C) 2019 Intel Corporation

 @license SPDX-License-Identifier: Apache-2.0

 @file demo_setup_teardown.py

 @brief This is a demo test file. This file includes setup and teardown routines called by robot to setup and teardown
     the test suite.

 @description
     This is a demo test file. This file includes setup and teardown routines called by robot to setup and teardown
     the test suite.

"""
import sys
import logging
import demo_tc_utils as utils
from TUC.data.SettingsInfo import SettingsInfo
from TUC.data.TestSettings import TestSettings
from TUC.report.ColorLog import ColorLog

__VERSION__ = '1.0'


"""
   Local utility routines are at the bottom of this file.
   These are routines which are used only by the testcase
   routines in this file.  Also, they are not directly called
   by robot.
"""


def demo_suite_setup(logfile, cfgfile, loglevel=None):

    """
    Suite_Setup sets up the test cases

    Gets the log and config and puts them in the SettingsInfo object

    The API between Robot and this script is that this script
    return True or False.  The policy here is catch exceptions,
    log them, and return False to Robot.

    @param logfile:   required logfile
    @param cfgfile:   required configuration file
    @param loglevel:  sets loglevel
    @retval    True returned to if all code was executed successfully.
    """
    tc_name = "Demo Suite Setup:"
    testcfg = TestSettings(cfgfile)
    for each_section in testcfg.sections():
        SettingsInfo().add_name(each_section, testcfg.get_section(each_section))
    SettingsInfo().add_name('testcfg', testcfg)
    tc_cfg_section = testcfg.get_section('Demo')
    if 'loglevel' in tc_cfg_section:
        lvl = tc_cfg_section['loglevel']
    else:
        lvl = loglevel if loglevel is not None else 'INFO'
    logging.getLogger().setLevel(lvl)
    testLog = ColorLog(filename=logfile, lvl=lvl, logName="demo", useBackGroundLogger=False)
    loglvl = logging.getLogger().getEffectiveLevel()
    utils.print_log_header(testLog)
    testLog.info('{} Logging started, level: {}'.format(tc_name, logging.getLevelName(loglvl)))
    testLog.info('{} python version: {}'.format(tc_name, sys.version))
    testLog.info('{} testcases version: {}'.format(tc_name, __VERSION__))
    testLog.info('{} Testcase configuration set from {}'.format(tc_name, cfgfile))
    SettingsInfo().add_name('TestLog', testLog)
    if not utils.verify_config(testcfg, testLog):
        testLog.error("{}: Check config file: it appears to be missing sections or items")
        return False
    return True


def demo_teardown():
    """
    Teardown the suite:
        print footer
        close the log file

    @retval True returned to robot
    """
    testLog = SettingsInfo().TestLog
    testLog.info("Demo teardown")

    utils.print_log_footer(testLog)
    testLog.close()

    return True


def demo_testcase_setup():
    """
    demo_testcase_setup is called to setup each testcase
    @retval True
    """
    return True


def demo_testcase_teardown():
    """
    demo_testcase_teardown is called to teardown each testcase

    @retval True
    """
    return True


def demo_initialize_test_state():
    """
    Establish the initial test state of the appliance

    After this test condition execution , the appliance should be running no
    application containers and there should be no out-
    standing jobs.

    @retval True
    """
    tc_name = "DEMO_INITIALIZE_TEST:"
    testLog = SettingsInfo().TestLog
    ut.print_tc_header(testLog, tc_name)
    ut.print_tc_footer(testLog, tc_name)
    return True
