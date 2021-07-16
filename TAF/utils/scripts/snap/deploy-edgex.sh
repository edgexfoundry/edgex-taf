#!/bin/bash

TEST_STRATEGY=${1:-}
APPSERVICE=${2:-}
CONF_DIR=/custom-config

sudo snap remove edgexfoundry
sudo snap remove edgex-device-modbus
sudo snap install edgexfoundry --channel=2.0/stable
sudo snap install edgex-device-modbus --channel=2.0/stable

# set up device-virtual - remove the DevicesDir setting and update the profile
sudo sed -i '/DevicesDir/d' /var/snap/edgexfoundry/current/config/device-virtual/res/configuration.toml
sudo rm /var/snap/edgexfoundry/current/config/device-virtual/res/profiles/*
sudo cp ${WORK_DIR}/TAF/config/device-virtual/sample_profile.yaml /var/snap/edgexfoundry/current/config/device-virtual/res/profiles

# set up device-modbus - remove the DevicesDir setting and update the profile
sudo sed -i '/DevicesDir/d' /var/snap/edgex-device-modbus/current/config/device-modbus/res/configuration.toml
sudo rm /var/snap/edgex-device-modbus/current/config/device-modbus/res/profiles/*
sudo cp ${WORK_DIR}/TAF/config/device-modbus/sample_profile.yaml /var/snap/edgex-device-modbus/current/config/device-modbus/res/profiles



if [ "$SECURITY_SERVICE_NEEDED" = "false" ]; then
    sudo snap set edgexfoundry security-secret-store=off
fi

sudo snap start edgexfoundry.support-notifications
sudo snap start edgexfoundry.support-scheduler
sudo snap start edgexfoundry.sys-mgmt-agent
sudo snap start edgexfoundry.device-virtual
sudo snap start edgex-device-modbus.device-modbus

if [ "$SECURITY_SERVICE_NEEDED" = "true" ]; then
    sleep 15
else
    sleep 5
fi

