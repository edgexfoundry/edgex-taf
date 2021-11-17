#!/bin/bash
>&2 echo "INFO:snap-TAF: shutdown.sh"


. "$SCRIPT_DIR/snap-utils.sh"

snap_remove_all

>&2 echo "INFO:snap: All EdgeX snaps removed"
>&2 echo "INFO:snap-TAF: shutdown"

