"""
 @copyright Copyright (C) 2019 Intel Corporation

 @license SPDX-License-Identifier: Apache-2.0

 @file Sample_Profile.py

 @brief This file is called from robot, note that robot is executing in TAF/testScenarios.

 @description
    This file is called from robot, note that robot is executing in TAF/testScenarios:
        robot -V ../config/profiles/Sample_Profile.py

     Notice the naming convention:
     - This file's location is TAF/config/profiles/
     - When this file is called by robot, the current working directory is
            robots current working directory, which is TAF/testScenarios
            so THESE LOCATIONS ARE RELATIVE TO ROBOTS WORKING DIRECTORY

"""

TAF_DIR = "../../"


def get_variables():
    """
    This function reads the file Sample_Profile.cfg and enable the usage of it's variables through the test execution.
    @retval     A Dictionary that holds the profile variables located at Sample_Profile.cfg
    """

    return {"PROFILE_PARAMS": {"Profile": TAF_DIR + "config/profiles/Sample_Profile.cfg"}}
