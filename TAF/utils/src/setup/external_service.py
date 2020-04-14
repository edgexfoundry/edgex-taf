"""
 @copyright Copyright (C) 2020 IOTech Ltd

 @license SPDX-License-Identifier: Apache-2.0

 @file external_service.py

 @description
    Helper functions to manage EdgeX deployment
"""
import subprocess
from TUC.data.SettingsInfo import SettingsInfo
import TAF.utils.src.setup.startup_checker as checker


def start_http_server():
    SettingsInfo().TestLog.info("Start Simple HTTP Server")
    subprocess.Popen("python {}/TAF/utils/src/setup/httpd_server.py &".format(SettingsInfo().workDir),
                            shell=True, close_fds=True)

