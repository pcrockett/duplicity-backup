#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
VARS_SCRIPT="$SCRIPT_DIR/vars.sh"

if [ ! -f "$VARS_SCRIPT" ]; then
  echo "Run install.sh first."
  exit 1
fi

source "$VARS_SCRIPT"

duplicity list-current-files "$@" "b2://$B2_KEY_ID:$B2_KEY@$B2_BUCKET"
