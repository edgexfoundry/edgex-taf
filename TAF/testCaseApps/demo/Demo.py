"""
 @copyright Copyright (C) 2019 Intel Corporation

 @license SPDX-License-Identifier: Apache-2.0

 @package: TAF.testCaseApps

 @file Demo.py

 @description
    This package contains demo class code, this us used in the robot file to execute each of the test case steps,
    each method must return True/False.
    This class shows the different log colors that can be used from edgex-taf-Common.TUC.report.ColorLog.py class
"""
import logging
from TUC.data.SettingsInfo import SettingsInfo


class Demo:
    """
    Class Demo
    """

    def __init__(self):
        """
        __init__ This method initialize the instance of the current class, this is called when the object is generated
        by the import in the robot file.
        @param    self   represents the instance of the class.
        """
        self.log = logging.getLogger(__name__)
        self.username = None

    def init_demo(self):
        """
        This method initialize the instance of the current class, this must be called after the config files have been
        initialized.
        @param    self   represents the instance of the class.
        """
        self.username = SettingsInfo().Demo['username']

    def log_username(self):
        """
        This method is an example on how to access the variables defined in the config files.
        @param    self   represents the instance of the class.
        @retval   True
        """

        SettingsInfo().TestLog.info('Username: {0}'.format(self.username))
        return True

    def test_debug(self):
        """
        This method is an example on debug usage.
        @param    self   represents the instance of the class.
        @retval   True
        """
        SettingsInfo().TestLog.debug('Debug: Hello World!!')
        return True

    def test_info(self):
        """
        This method is an example on info usage.
        @param    self   represents the instance of the class.
        @retval   True
        """
        SettingsInfo().TestLog.info('Info: Hello World!!')
        return True

    def test_warn(self):
        """
        This method is an example on warn usage.
        @param    self   represents the instance of the class.
        @retval   True
        """
        SettingsInfo().TestLog.warn('Warn: Hello World!!')
        return True

    def test_error(self):
        """
        This method is an example on error usage.
        @param    self   represents the instance of the class.
        @retval   True
        """
        SettingsInfo().TestLog.error('Error: Hello World!!')
        return True

    def test_log_exception(self):
        """
        This method is an example on debug usage.
        @param    self   represents the instance of the class.
        @retval   True
        """
        SettingsInfo().TestLog.warn('Log Exception: Hello World!!')
        return True

    def test_pass(self):
        """
        This method is an example on pass log usage.
        @param    self   represents the instance of the class.
        @retval   True
        """
        SettingsInfo().TestLog.PASS('Pass: Hello World!!')
        return True

    def test_fail(self):
        """
        This method is an example on fail log usage.
        @param    self   represents the instance of the class.
        @retval   True
        """
        SettingsInfo().TestLog.FAIL('Fail: Hello World!!')
        return True

    def test_heading(self):
        """
        This method is an example on heading log usage.
        @param    self   represents the instance of the class.
        @retval   True
        """
        SettingsInfo().TestLog.HEADING('HEADING: Hello World!!')
        return True
