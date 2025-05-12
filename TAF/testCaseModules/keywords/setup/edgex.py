"""
 @copyright Copyright (C) 2019 IOTech Ltd

 @license SPDX-License-Identifier: Apache-2.0

 @file edgex.py

 @description
    Helper functions to manage EdgeX deployment
"""
import subprocess

from TUC.data.SettingsInfo import SettingsInfo
from TAF.testCaseModules.keywords.setup import startup_checker as checker


def deploy_edgex(*args):
    SettingsInfo().TestLog.info('Deploy EdgeX')
    cmd = ["sh", "{}/TAF/utils/scripts/{}/deploy-edgex.sh".format(SettingsInfo().workDir,
                                                                  SettingsInfo().constant.DEPLOY_TYPE),
           *args]
    run_command(cmd)

    checker.check_services_startup(["data", "metadata", "command", "support-notifications", "device-virtual"])


def shutdown_services(*args):
    SettingsInfo().TestLog.info("Shutdown all services")
    script_path = "{}/TAF/utils/scripts/{}/shutdown.sh".format(
        SettingsInfo().workDir,
        SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path, *args]
    run_command(cmd)


def stop_services(*args):
    SettingsInfo().TestLog.info("Stop services {}".format(args))
    script_path = "{}/TAF/utils/scripts/{}/stop-services.sh".format(
        SettingsInfo().workDir,
        SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path, *args]
    run_command(cmd)


def restart_services(*args):
    SettingsInfo().TestLog.info("Restart services {}".format(args))
    script_path = "{}/TAF/utils/scripts/{}/restart-services.sh".format(
            SettingsInfo().workDir,
            SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path, *args]
    run_command(cmd)
    checker.check_services_startup(list(args))


def remove_services(*args):
    SettingsInfo().TestLog.info("Remove services {}".format(args))
    script_path = "{}/TAF/utils/scripts/{}/remove-services.sh".format(
        SettingsInfo().workDir,
        SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path, *args]
    run_command(cmd)


def deploy_device_service(device_service, profile=SettingsInfo().tafConfig):
    SettingsInfo().TestLog.info('Deploy device service {} with profile {}'.format(device_service, profile))
    cmd = ["sh", "{}/TAF/utils/scripts/{}/deploy-device-service.sh".format(SettingsInfo().workDir,
                                                                           SettingsInfo().constant.DEPLOY_TYPE),
           device_service, profile]
    run_command(cmd)
    checker.check_service_startup_by_log(device_service)


def run_command(cmd):
    p = subprocess.Popen(cmd, stderr=subprocess.PIPE)
    for line in p.stderr:
        SettingsInfo().TestLog.info(line.decode("utf-8"))

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


def deploy_services(*args):
    SettingsInfo().TestLog.info("Deploy services {}".format(args))
    cmd = ["sh", "{}/TAF/utils/scripts/{}/deploy-services.sh".format(SettingsInfo().workDir,
                                                                    SettingsInfo().constant.DEPLOY_TYPE),
           *args]
    run_command(cmd)
    checker.check_services_startup([*args])


def access_token(arg):
    cmd = ["sh", "{}/TAF/utils/scripts/{}/api-gateway-token.sh".format(SettingsInfo().workDir,
                                                                       SettingsInfo().constant.DEPLOY_TYPE),
           arg]
    try:
        output = subprocess.run(cmd, stdout=subprocess.PIPE, check=True).stdout.decode('utf-8').rstrip('\n')
        SettingsInfo().TestLog.info("./api-gateway-token.sh {} output: {} ".format(arg, output))
        return output
    except subprocess.CalledProcessError as e:
        msg = "Fail to execute cmd: " + " ".join(str(x) for x in cmd)
        SettingsInfo().TestLog.info("exit " + str(e.returncode))
        SettingsInfo().TestLog.error(msg)
        raise Exception(msg)
