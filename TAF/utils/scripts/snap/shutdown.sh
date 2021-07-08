#!/bin/bash

snap remove --purge edgex-device-mqtt
snap remove --purge edgex-device-modbus
snap remove --purge edgex-device-camera
snap remove --purge edgex-device-rest
snap remove --purge edgex-app-service-configurable
snap remove --purge edgexfoundry

>&2 echo "INFO:snap: All EdgeX snaps removed"
logger "INFO:snap-TAF: shutdown"

