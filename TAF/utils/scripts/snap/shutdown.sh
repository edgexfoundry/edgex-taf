#!/bin/bash

sudo snap remove edgex-device-mqtt
sudo snap remove edgex-device-modbus
sudo snap remove edgex-device-camera
sudo snap remove edgex-device-rest
sudo snap remove edgex-app-service-configurable
sudo snap remove edgexfoundry
logger "[snap] All EdgeX snaps removed"