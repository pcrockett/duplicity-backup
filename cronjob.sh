#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
VARS_SCRIPT="$SCRIPT_DIR/vars.sh"
RUN_SCRIPT="$SCRIPT_DIR/run.sh"

source "$VARS_SCRIPT"

& "$RUN_SCRIPT"

# This will only execute when the run script exits with a good status code
curl -fsS --retry 3 "$PING_URL" > /dev/null;
