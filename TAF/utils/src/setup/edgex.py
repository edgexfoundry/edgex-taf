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


def deploy_edgex():
    SettingsInfo().TestLog.info('Deploy EdgeX')
    cmd = ["sh", "{}/TAF/utils/scripts/{}/deploy-edgex.sh".format(SettingsInfo().workDir,
                                                                  SettingsInfo().constant.DEPLOY_TYPE)]
    run_command(cmd)

    checker.check_services_startup(["data", "metadata", "command", "support-logging", "support-notifications"])


def shutdown_services():
    SettingsInfo().TestLog.info("Shutdown all services")
    script_path = "{}/TAF/utils/scripts/{}/shutdown.sh".format(
        SettingsInfo().workDir,
        SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path]
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


def remove_services(*args):
    SettingsInfo().TestLog.info("Remove services {}".format(args))
    script_path = "{}/TAF/utils/scripts/{}/remove-services.sh".format(
        SettingsInfo().workDir,
        SettingsInfo().constant.DEPLOY_TYPE)
    cmd = ["sh", script_path, *args]
    run_command(cmd)


def deploy_device_service(device_service):
    SettingsInfo().TestLog.info('Deploy device service {}'.format(device_service))
    cmd = ["sh", "{}/TAF/utils/scripts/{}/deploy-device-service.sh".format(SettingsInfo().workDir,
                                                                           SettingsInfo().constant.DEPLOY_TYPE),
           device_service]
    run_command(cmd)


def deploy_device_service_with_registry_url(device_service, registry_url):
    SettingsInfo().TestLog.info('Deploy device service {} with registry url {}'.format(device_service, registry_url))
    cmd = ["sh", "{}/TAF/utils/scripts/{}/deploy-device-service-with-registry-url.sh".format(SettingsInfo().workDir,
                                                                                             SettingsInfo().constant.DEPLOY_TYPE),
           device_service, registry_url]
    run_command(cmd)

    checker.check_services_startup([device_service, registry_url])


def deploy_device_service_with_the_confdir_option(device_service, confdir):
    SettingsInfo().TestLog.info('Deploy device service {} with confdir option {}'.format(device_service, confdir))
    cmd = ["sh", "{}/TAF/utils/scripts/{}/deploy-device-service-with-confdir-option.sh".format(SettingsInfo().workDir,
                                                                                               SettingsInfo().constant.DEPLOY_TYPE),
           device_service, confdir]
    run_command(cmd)

    checker.check_services_startup([device_service, confdir])


def deploy_device_service_with_the_profile_option(device_service, profile):
    SettingsInfo().TestLog.info('Deploy device service {} with confdir option {}'.format(device_service, profile))
    cmd = ["sh", "{}/TAF/utils/scripts/{}/deploy-device-service-with-profile-option.sh".format(SettingsInfo().workDir,
                                                                                               SettingsInfo().constant.DEPLOY_TYPE),
           device_service, profile]
    run_command(cmd)

    checker.check_services_startup([device_service, profile])


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
