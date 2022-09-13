"""
 @copyright Copyright (C) 2020 IOTech Ltd

 @license SPDX-License-Identifier: Apache-2.0

 @file RetrieveFootprint.py

 @description

"""
import os
import platform
import traceback
import docker
from robot.api import logger
from TUC.data.SettingsInfo import SettingsInfo

client = docker.from_env()

global services
services = {
    "edgex-core-consul": {"binary": ""},
    "edgex-core-data": {"binary": "/core-data"},
    "edgex-core-metadata": {"binary": "/core-metadata"},
    "edgex-core-command": {"binary": "/core-command"},
    "edgex-support-notifications": {"binary": "/support-notifications"},
    "edgex-support-scheduler": {"binary": "/support-scheduler"},
    "edgex-app-rules-engine": {"binary": "/app-service-configurable"},
    "edgex-sys-mgmt-agent": {"binary": "/sys-mgmt-agent"},
    "edgex-device-virtual": {"binary": "/device-virtual"},
    "edgex-device-rest": {"binary": "/device-rest"},
    "edgex-kuiper": {"binary": ""},
    "edgex-redis": {"binary": ""},
    "edgex-security-proxy-setup": {"binary": ""},
    "edgex-security-secretstore-setup": {"binary": ""},
    "edgex-kong": {"binary": ""},
    "edgex-kong-db": {"binary": ""},
    "edgex-vault": {"binary": ""},
    "edgex-security-bootstrapper": {"binary": ""},
    "edgex-security-spiffe-token-provider": {"binary": ""},
    "edgex-security-spire-agent": {"binary": ""},
    "edgex-security-spire-config": {"binary": ""},
    "edgex-security-spire-server": {"binary": ""}
}

prior_rel_image_footprint = {
    "edgex-core-consul": {"imagesize": "{}".format(SettingsInfo().profile_constant.CONSUL_IMAGE)},
    "edgex-core-data": {"imagesize": "{}".format(SettingsInfo().profile_constant.DATA_IMAGE)},
    "edgex-core-metadata": {"imagesize": "{}".format(SettingsInfo().profile_constant.METADATA_IMAGE)},
    "edgex-core-command": {"imagesize": "{}".format(SettingsInfo().profile_constant.COMMAND_IMAGE)},
    "edgex-support-notifications": {"imagesize": "{}".format(SettingsInfo().profile_constant.NOTIFICATIONS_IMAGE)},
    "edgex-support-scheduler": {"imagesize": "{}".format(SettingsInfo().profile_constant.SCHEDULER_IMAGE)},
    "edgex-app-rules-engine": {"imagesize": "{}".format(SettingsInfo().profile_constant.APP_SERVICE_CONFIGURABLE_IMAGE)},
    "edgex-sys-mgmt-agent": {"imagesize": "{}".format(SettingsInfo().profile_constant.SYS_MGMT_AGENT_IMAGE)},
    "edgex-device-virtual": {"imagesize": "{}".format(SettingsInfo().profile_constant.DEVICE_VIRTUAL_IMAGE)},
    "edgex-device-rest": {"imagesize": "{}".format(SettingsInfo().profile_constant.DEVICE_REST_IMAGE)},
    "edgex-kuiper": {"imagesize": "{}".format(SettingsInfo().profile_constant.KUIPER_IMAGE)},
    "edgex-redis": {"imagesize": "{}".format(SettingsInfo().profile_constant.REDIS_IMAGE)},
    "edgex-security-proxy-setup": {"imagesize": "{}".format(SettingsInfo().profile_constant.PROXY_IMAGE)},
    "edgex-security-secretstore-setup": {"imagesize": "{}".format(SettingsInfo().profile_constant.SECRETSTORE_IMAGE)},
    "edgex-kong": {"imagesize": "{}".format(SettingsInfo().profile_constant.KONG_IMAGE)},
    "edgex-kong-db": {"imagesize": "{}".format(SettingsInfo().profile_constant.KONG_DB_IMAGE)},
    "edgex-vault": {"imagesize": "{}".format(SettingsInfo().profile_constant.VAULT_IMAGE)},
    "edgex-security-bootstrapper": {"imagesize": "{}".format(SettingsInfo().profile_constant.BOOTSTRAPPER_IMAGE)},
    "edgex-security-spiffe-token-provider": {"imagesize": "{}".format(SettingsInfo().profile_constant.SPIFFE_TOKEN_IMAGE)},
    "edgex-security-spire-agent": {"imagesize": "{}".format(SettingsInfo().profile_constant.SPIRE_AGENT_IMAGE)},
    "edgex-security-spire-config": {"imagesize": "{}".format(SettingsInfo().profile_constant.SPIRE_CONFIG_IMAGE)},
    "edgex-security-spire-server": {"imagesize": "{}".format(SettingsInfo().profile_constant.SPIRE_SERVER_IMAGE)}
}

prior_rel_image_footprint_arm64 = {
    "edgex-core-consul": {"imagesize": "{}".format(SettingsInfo().profile_constant.CONSUL_IMAGE_ARM64)},
    "edgex-core-data": {"imagesize": "{}".format(SettingsInfo().profile_constant.DATA_IMAGE_ARM64)},
    "edgex-core-metadata": {"imagesize": "{}".format(SettingsInfo().profile_constant.METADATA_IMAGE_ARM64)},
    "edgex-core-command": {"imagesize": "{}".format(SettingsInfo().profile_constant.COMMAND_IMAGE_ARM64)},
    "edgex-support-notifications": {"imagesize": "{}".format(SettingsInfo().profile_constant.NOTIFICATIONS_IMAGE_ARM64)},
    "edgex-support-scheduler": {"imagesize": "{}".format(SettingsInfo().profile_constant.SCHEDULER_IMAGE_ARM64)},
    "edgex-app-rules-engine": {"imagesize": "{}".format(SettingsInfo().profile_constant.APP_SERVICE_CONFIGURABLE_IMAGE_ARM64)},
    "edgex-sys-mgmt-agent": {"imagesize": "{}".format(SettingsInfo().profile_constant.SYS_MGMT_AGENT_IMAGE_ARM64)},
    "edgex-device-virtual": {"imagesize": "{}".format(SettingsInfo().profile_constant.DEVICE_VIRTUAL_IMAGE_ARM64)},
    "edgex-device-rest": {"imagesize": "{}".format(SettingsInfo().profile_constant.DEVICE_REST_IMAGE_ARM64)},
    "edgex-kuiper": {"imagesize": "{}".format(SettingsInfo().profile_constant.KUIPER_IMAGE_ARM64)},
    "edgex-redis": {"imagesize": "{}".format(SettingsInfo().profile_constant.REDIS_IMAGE_ARM64)},
    "edgex-security-proxy-setup": {"imagesize": "{}".format(SettingsInfo().profile_constant.PROXY_IMAGE_ARM64)},
    "edgex-security-secretstore-setup": {"imagesize": "{}".format(SettingsInfo().profile_constant.SECRETSTORE_IMAGE_ARM64)},
    "edgex-kong": {"imagesize": "{}".format(SettingsInfo().profile_constant.KONG_IMAGE_ARM64)},
    "edgex-kong-db": {"imagesize": "{}".format(SettingsInfo().profile_constant.KONG_DB_IMAGE_ARM64)},
    "edgex-vault": {"imagesize": "{}".format(SettingsInfo().profile_constant.VAULT_IMAGE_ARM64)},
    "edgex-security-bootstrapper": {"imagesize": "{}".format(SettingsInfo().profile_constant.BOOTSTRAPPER_IMAGE_ARM64)},
    "edgex-security-spiffe-token-provider": {"imagesize": "{}".format(SettingsInfo().profile_constant.SPIFFE_TOKEN_IMAGE_ARM64)},
    "edgex-security-spire-agent": {"imagesize": "{}".format(SettingsInfo().profile_constant.SPIRE_AGENT_IMAGE_ARM64)},
    "edgex-security-spire-config": {"imagesize": "{}".format(SettingsInfo().profile_constant.SPIRE_CONFIG_IMAGE_ARM64)},
    "edgex-security-spire-server": {"imagesize": "{}".format(SettingsInfo().profile_constant.SPIRE_SERVER_IMAGE_ARM64)}
}

prior_rel_binary_footprint = {
    "edgex-core-consul": {"binarysize": "{}".format(SettingsInfo().profile_constant.CONSUL_BINARY)},
    "edgex-core-data": {"binarysize": "{}".format(SettingsInfo().profile_constant.DATA_BINARY)},
    "edgex-core-metadata": {"binarysize": "{}".format(SettingsInfo().profile_constant.METADATA_BINARY)},
    "edgex-core-command": {"binarysize": "{}".format(SettingsInfo().profile_constant.COMMAND_BINARY)},
    "edgex-support-notifications": {"binarysize": "{}".format(SettingsInfo().profile_constant.NOTIFICATIONS_BINARY)},
    "edgex-support-scheduler": {"binarysize": "{}".format(SettingsInfo().profile_constant.SCHEDULER_BINARY)},
    "edgex-app-rules-engine": {"binarysize": "{}".format(SettingsInfo().profile_constant.APP_SERVICE_CONFIGURABLE_BINARY)},
    "edgex-sys-mgmt-agent": {"binarysize": "{}".format(SettingsInfo().profile_constant.SYS_MGMT_AGENT_BINARY)},
    "edgex-device-virtual": {"binarysize": "{}".format(SettingsInfo().profile_constant.DEVICE_VIRTUAL_BINARY)},
    "edgex-device-rest": {"binarysize": "{}".format(SettingsInfo().profile_constant.DEVICE_REST_BINARY)},
    "edgex-kuiper": {"binarysize": "{}".format(SettingsInfo().profile_constant.KUIPER_BINARY)},
    "edgex-redis": {"binarysize": "{}".format(SettingsInfo().profile_constant.REDIS_BINARY)},
    "edgex-security-proxy-setup": {"binarysize": "{}".format(SettingsInfo().profile_constant.PROXY_BINARY)},
    "edgex-security-secretstore-setup": {"binarysize": "{}".format(SettingsInfo().profile_constant.SECRETSTORE_BINARY)},
    "edgex-kong": {"binarysize": "{}".format(SettingsInfo().profile_constant.KONG_BINARY)},
    "edgex-kong-db": {"binarysize": "{}".format(SettingsInfo().profile_constant.KONG_DB_BINARY)},
    "edgex-vault": {"binarysize": "{}".format(SettingsInfo().profile_constant.VAULT_BINARY)},
    "edgex-security-bootstrapper": {"binarysize": "{}".format(SettingsInfo().profile_constant.BOOTSTRAPPER_BINARY)},
    "edgex-security-spiffe-token-provider": {"binarysize": "{}".format(SettingsInfo().profile_constant.SPIFFE_TOKEN_BINARY)},
    "edgex-security-spire-agent": {"binarysize": "{}".format(SettingsInfo().profile_constant.SPIRE_AGENT_BINARY)},
    "edgex-security-spire-config": {"binarysize": "{}".format(SettingsInfo().profile_constant.SPIRE_CONFIG_BINARY)},
    "edgex-security-spire-server": {"binarysize": "{}".format(SettingsInfo().profile_constant.SPIRE_SERVER_BINARY)}
}

prior_rel_binary_footprint_arm64 = {
    "edgex-core-consul": {"binarysize": "{}".format(SettingsInfo().profile_constant.CONSUL_BINARY)},
    "edgex-core-data": {"binarysize": "{}".format(SettingsInfo().profile_constant.DATA_BINARY_ARM64)},
    "edgex-core-metadata": {"binarysize": "{}".format(SettingsInfo().profile_constant.METADATA_BINARY_ARM64)},
    "edgex-core-command": {"binarysize": "{}".format(SettingsInfo().profile_constant.COMMAND_BINARY_ARM64)},
    "edgex-support-notifications": {"binarysize": "{}".format(SettingsInfo().profile_constant.NOTIFICATIONS_BINARY_ARM64)},
    "edgex-support-scheduler": {"binarysize": "{}".format(SettingsInfo().profile_constant.SCHEDULER_BINARY_ARM64)},
    "edgex-app-rules-engine": {"binarysize": "{}".format(SettingsInfo().profile_constant.APP_SERVICE_CONFIGURABLE_BINARY_ARM64)},
    "edgex-sys-mgmt-agent": {"binarysize": "{}".format(SettingsInfo().profile_constant.SYS_MGMT_AGENT_BINARY_ARM64)},
    "edgex-device-virtual": {"binarysize": "{}".format(SettingsInfo().profile_constant.DEVICE_VIRTUAL_BINARY_ARM64)},
    "edgex-device-rest": {"binarysize": "{}".format(SettingsInfo().profile_constant.DEVICE_REST_BINARY_ARM64)},
    "edgex-kuiper": {"binarysize": "{}".format(SettingsInfo().profile_constant.KUIPER_BINARY)},
    "edgex-redis": {"binarysize": "{}".format(SettingsInfo().profile_constant.REDIS_BINARY)},
    "edgex-security-proxy-setup": {"binarysize": "{}".format(SettingsInfo().profile_constant.PROXY_BINARY)},
    "edgex-security-secretstore-setup": {"binarysize": "{}".format(SettingsInfo().profile_constant.SECRETSTORE_BINARY)},
    "edgex-kong": {"binarysize": "{}".format(SettingsInfo().profile_constant.KONG_BINARY)},
    "edgex-kong-db": {"binarysize": "{}".format(SettingsInfo().profile_constant.KONG_DB_BINARY)},
    "edgex-vault": {"binarysize": "{}".format(SettingsInfo().profile_constant.VAULT_BINARY)},
    "edgex-security-bootstrapper": {"binarysize": "{}".format(SettingsInfo().profile_constant.BOOTSTRAPPER_BINARY)},
    "edgex-security-spiffe-token-provider": {"binarysize": "{}".format(SettingsInfo().profile_constant.SPIFFE_TOKEN_BINARY)},
    "edgex-security-spire-agent": {"binarysize": "{}".format(SettingsInfo().profile_constant.SPIRE_AGENT_BINARY)},
    "edgex-security-spire-config": {"binarysize": "{}".format(SettingsInfo().profile_constant.SPIRE_CONFIG_BINARY)},
    "edgex-security-spire-server": {"binarysize": "{}".format(SettingsInfo().profile_constant.SPIRE_SERVER_BINARY)}
}

exclude_services = ["edgex-kuiper", "edgex-redis", "edgex-core-consul"]
exclude_secty_services = ["edgex-security-proxy-setup", "edgex-security-secretstore-setup", "edgex-kong", "edgex-kong-db", "edgex-vault",
                          "edgex-security-bootstrapper"]
exclude_delayed_start_services = ["edgex-security-spiffe-token-provider", "edgex-security-spire-agent", "edgex-security-spire-config",
                                  "edgex-security-spire-server"]

secty_services = []
secty_services.extend(exclude_secty_services)
secty_services.extend(exclude_delayed_start_services)

class RetrieveFootprint(object):

    def __init__(self):
        self._result = ""

    def fetch_image_binary_footprint(self):
        global resource_usage
        resource_usage = {}
        test_services = get_services(services)

        for k in test_services:
            resource_usage[k] = fetch_footprint_by_service(k)

    def show_the_summary_table(self):
        show_the_summary_table_in_html(resource_usage)

    def image_footprint_is_less_than_threshold_value(self):
        compare_image_footprint_size_with_prior_release(resource_usage)

    def binary_footprint_is_less_than_threshold_value(self):
        compare_binary_footprint_size_with_prior_release(resource_usage)


def get_services(services_dict):
    security_enabled = os.getenv("SECURITY_SERVICE_NEEDED")
    if security_enabled != 'true':
        for k in list(services_dict):
            if k in secty_services:
                services_dict.pop(k)
    return services_dict


def fetch_footprint_by_service(service):
    containerName = service
    usage = {}
    try:
        container = client.containers.get(containerName)
        imageName = container.attrs["Config"]["Image"]
        image = client.images.get(imageName)
        imageSize = image.attrs["Size"]

        # prior release image and binary size
        arch = platform.machine()
        print("arch:"+arch)
        if arch == "x86_64":
            priorImageSize = prior_rel_image_footprint[containerName]["imagesize"]
            priorBinarySize = prior_rel_binary_footprint[containerName]["binarysize"]
        else:
            priorImageSize = prior_rel_image_footprint_arm64[containerName]["imagesize"]
            priorBinarySize = prior_rel_binary_footprint_arm64[containerName]["binarysize"]

        if not services[containerName]["binary"]:
            binarySize = 0
        else:
            _, stat = container.get_archive(services[containerName]["binary"])
            binarySize = stat["size"]

        usage["imageFootprint"] = format(int(imageSize) / 1000000, '.2f')
        usage["binaryFootprint"] = format(int(binarySize) / 1000000, '.2f')
        usage["priorImageFootprint"] = priorImageSize
        usage["priorBinaryFootprint"] = priorBinarySize
        logger.info(containerName + " " + str(usage))

    except docker.errors.NotFound as error:
        usage["imageFootprint"] = 0
        usage["binaryFootprint"] = 0
        logger.error(containerName + " container not found")
        logger.error(error)
    except:
        usage["imageFootprint"] = 0
        usage["binaryFootprint"] = 0
        logger.error(containerName + " fail to fetch resource usage")
        logger.error(traceback.format_exc())

    return usage


def compare_image_footprint_size_with_prior_release(usages):
    isfailed = 0
    for k in usages:
        if k not in exclude_services and k not in secty_services:
            threshold_limit = float(usages[k]["priorImageFootprint"]) * float(SettingsInfo().profile_constant.FOOTPRINT_THRESHOLD)
            try:
                if float(usages[k]["priorImageFootprint"]) != 0.0:
                    if float(usages[k]["imageFootprint"]) >= threshold_limit:
                        logger.error("{} image size {} > Prior release size {} * {}".
                                        format(k, str(usages[k]["imageFootprint"]), str(usages[k]["priorImageFootprint"]),
                                               str(SettingsInfo().profile_constant.FOOTPRINT_THRESHOLD)))
                        isfailed = 1

                else:
                    # Failure if no prior release image and current image size is over than 100MB
                    if float(usages[k]["imageFootprint"]) >= 100.0:
                        logger.error("{} image size is over than 100MB".format(k))
                        isfailed = 1
            except:
                pass

    if isfailed == 1:
        raise Exception("One of container image size is abnormal")


def compare_binary_footprint_size_with_prior_release(usages):
    isfailed = 0
    for k in usages:
        if k not in exclude_services and k not in secty_services:
            threshold_limit = float(usages[k]["priorBinaryFootprint"]) * float(SettingsInfo().profile_constant.FOOTPRINT_THRESHOLD)
            try:
                if float(usages[k]["priorBinaryFootprint"]) != 0.0:
                    if float(usages[k]["binaryFootprint"]) >= threshold_limit:
                        logger.error("{} binary size {} > Prior release size {} * {}".
                                     format(k, str(usages[k]["binaryFootprint"]), str(usages[k]["priorBinaryFootprint"]),
                                            str(SettingsInfo().profile_constant.FOOTPRINT_THRESHOLD)))
                        isfailed = 1
                else:
                    # Failure if prior release is no binary file and current binary size is over than 50MB
                    if float(usages[k]["binaryFootprint"]) >= 50.0:
                        logger.error("{} binary size is over than 50MB".format(k))
                        isfailed = 1
            except:
                pass

    if isfailed == 1:
        raise Exception("One of container binary size is abnormal")


def show_the_summary_table_in_html(usages):
    html = """ 
    <h3 style="margin:0px">Image / Executable Footprint:</h3>
    <h4 style="margin:0px;color:blue">Threshold Setting: Kamakura value * {} </h4>
    <div style="margin:0px">We don't retrieve the executable footprint of the third party services, so the tabale show 0.00 MB here</div>
    <table style="border: 1px solid black;white-space: initial;"> 
        <tr style="border: 1px solid black;">
            <th style="border: 1px solid black;">
                Micro service			 	 
            </th>
            <th style="border: 1px solid black;">
                Current Image Footprint
            </th>
            <th style="border: 1px solid black;">
                Prior Release Image Footprint
            </th>
            <th style="border: 1px solid black;">
                Current Executable Footprint
            </th>
            <th style="border: 1px solid black;">
                Prior Release Executable Footprint
            </th>
        </tr>
    """.format(SettingsInfo().profile_constant.FOOTPRINT_THRESHOLD)

    for k in usages:
        html = html + """ 
        <tr style="border: 1px solid black;">
            <td style="border: 1px solid black;">
                {}			 	 
            </td>
            <td style="border: 1px solid black;">
                {} MB
            </td>
            <td style="border: 1px solid black;">
                {} MB
            </td>
            <td style="border: 1px solid black;">
                {} MB
            </td>
            <td style="border: 1px solid black;">
                {} MB
            </td>
        </tr>
    """.format(
            k, usages[k]["imageFootprint"], usages[k]["priorImageFootprint"], usages[k]["binaryFootprint"],
            usages[k]["priorBinaryFootprint"]
        )

    html = html + "</table>"
    logger.info(html, html=True)
    return html
