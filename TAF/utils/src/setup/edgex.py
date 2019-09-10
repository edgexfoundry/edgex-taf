"""
 @copyright Copyright (C) 2019 IOTech Ltd

 @license SPDX-License-Identifier: Apache-2.0

 @file edgex.py

 @description
    Helper functions to manage EdgeX deployment
"""
import subprocess
from TUC.data.SettingsInfo import SettingsInfo
import TAF.utils.src.setup.startup_checker as checker


def deploy_services(*args):
    SettingsInfo().TestLog.info('Deploy services {}'.format(args))
    cmd = ["sh", "{}/TAF/utils/scripts/{}/startup.sh".format(SettingsInfo().workDir, SettingsInfo().constant.DEPLOY_TYPE), *args]
    run_command(cmd)

    checker.check_services_startup(args)


def shutdown_services():
    SettingsInfo().TestLog.info("Shutdown all service")
    script_path = "{}/TAF/utils/scripts/{}/shutdown.sh".format(
        SettingsInfo().workDir,
        SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path]
    run_command(cmd)


def stop_services(*args):
    SettingsInfo().TestLog.info("Stop service {}".format(args))
    script_path = "{}/TAF/utils/scripts/{}/stop-services.sh".format(
        SettingsInfo().workDir,
        SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path, *args]
    run_command(cmd)


def restart_services(*args):
    SettingsInfo().TestLog.info("Restart service {}".format(args))
    script_path = "{}/TAF/utils/scripts/{}/restart-services.sh".format(
            SettingsInfo().workDir,
            SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path, *args]
    run_command(cmd)


def run_command(cmd):
    p = subprocess.Popen(cmd, stderr=subprocess.PIPE)
    for line in p.stderr:
        SettingsInfo().TestLog.info(line)

    p.wait()
    SettingsInfo().TestLog.info("exit " + str(p.returncode))
    if p.returncode != 0:
        msg = "Fail to execute cmd: " + " ".join(str(x) for x in cmd)
        SettingsInfo().TestLog.error(msg)
        raise Exception(msg)
    else:
        msg = "Success to execute cmd: " + " ".join(str(x) for x in cmd)
        SettingsInfo().TestLog.info(msg)


def echo(obj):
    SettingsInfo().TestLog.info("Test echo: {}".format(obj))