#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
VARS_SCRIPT="$SCRIPT_DIR/vars.sh"
RESTORE_DIR="$SCRIPT_DIR/restore"

if [ ! -f "$VARS_SCRIPT" ]; then
  echo "Run install.sh first."
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Expecting 1 argument: The file to restore."
  exit 1
fi

if [ ! -d "$RESTORE_DIR" ]; then
  mkdir "$RESTORE_DIR"
fi

source "$VARS_SCRIPT"

FILE_TO_RESTORE="$1"

echo "Restoring to $RESTORE_DIR..."
echo "If asked for a passphrase, leave blank and hit enter."

PASSPHRASE="$GPG_PASSPHRASE"
duplicity restore \
  --file-to-restore "$FILE_TO_RESTORE" \
  --sign-key "$GPG_SIGN_KEY" \
  --encrypt-key "$GPG_ENCR_KEY" \
  "b2://$B2_KEY_ID:$B2_KEY@$B2_BUCKET" "$RESTORE_DIR"
