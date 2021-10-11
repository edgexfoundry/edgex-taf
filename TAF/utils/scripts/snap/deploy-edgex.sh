#!/bin/bash
set -e
logger "INFO:snap-TAF: deploy-edgex.sh"

. "$SCRIPT_DIR/snap-utils.sh"

snap_remove_all
snap_install_all
sleep 5 