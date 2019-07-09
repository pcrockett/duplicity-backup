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

GPG_PASSPHRASE=""

mount_all() {

  for share in ${SHARES[@]}; do

    if [ ! -d "$MOUNT_DIR/$share" ]; then
      mkdir "$MOUNT_DIR/$share"
    fi

    mount -t cifs \
      -o "username=$NAS_USERNAME,password=$NAS_PASSWORD,vers=2.0" \
      "//$NAS_HOST/$share" "$MOUNT_DIR/$share"
  done

}

unmount_all() {
  for share in ${SHARES[@]}; do
    umount "//$NAS_HOST/$share"
  done
}

run_backup() {
  export PASSPHRASE="$GPG_PASSPHRASE"
  duplicity "$MOUNT_DIR" "b2://$B2_KEY_ID:$B2_KEY@$B2_BUCKET" \
    --sign-key "$GPG_KEY" \
    --encrypt-key "$GPG_KEY" \
    --encrypt-key "$GPG_OFFLINE_KEY"
}

mount_all
run_backup || true
unmount_all
