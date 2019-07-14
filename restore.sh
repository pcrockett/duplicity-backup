#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
VARS_SCRIPT="$SCRIPT_DIR/vars.sh"

if [ ! -f "$VARS_SCRIPT" ]; then
  echo "Run install.sh first."
  exit 1
fi

if [ $# -ne 3 ]; then
  echo "Expecting 3 arguments: The share name, the file / directory path to restore, and the destination path."
  exit 1
fi

source "$VARS_SCRIPT"

SHARE="$1"
FILE_TO_RESTORE="$2"
DEST_PATH="$3"

echo "Restoring to $DEST_PATH..."
echo "If asked for a passphrase, leave blank and hit enter."

PASSPHRASE="$GPG_PASSPHRASE"
duplicity restore \
  --file-to-restore "$FILE_TO_RESTORE" \
  --sign-key "$GPG_SIGN_KEY" \
  --encrypt-key "$GPG_ENCR_KEY" \
  "b2://$B2_KEY_ID:$B2_KEY@$B2_BUCKET/$SHARE/" "$DEST_PATH"
