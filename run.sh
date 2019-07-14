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

mount_share() {

  share="$1"

  if [ ! -d "$MOUNT_DIR/$share" ]; then
    mkdir "$MOUNT_DIR/$share"
  fi

  if mountpoint -q "$MOUNT_DIR/$share"; then
    # Do nothing; already mounted
  else
    mount -t cifs \
      -o "username=$NAS_USERNAME,password=$NAS_PASSWORD,vers=2.0,file_mode=0400,dir_mode=0500,gid=$BACKUP_GID,uid=$BACKUP_UID" \
      "//$NAS_HOST/$share" "$MOUNT_DIR/$share"
  fi
}

unmount_share() {

  share="$1"

  if mountpoint -q "$MOUNT_DIR/$share"; then
    umount "//$NAS_HOST/$share"
  fi
}

backup_share() {

  share="$1"

  sudo -u "$BACKUP_USER" \
    PASSPHRASE="$GPG_PASSPHRASE" \
    SIGN_PASSPHRASE="$GPG_PASSPHRASE" \
    duplicity "$MOUNT_DIR" "b2://$B2_KEY_ID:$B2_KEY@$B2_BUCKET/$share/" \
      --sign-key "$GPG_SIGN_KEY" \
      --encrypt-key "$GPG_ENCR_KEY!" \
      --encrypt-key "$GPG_OFFLINE_KEY!"
}

run_backup() {
  
  backup_status=0

  for share in ${SHARES[@]}; do

    echo "Backing up $share..."

    mount_share $share
    
    if backup_share $share; then
      echo "$share backed up successfully."
    else
      # Failure. Make sure we exit this function with a failed exit code
      backup_status=1
      echo "$share backup failure."
    fi

    unmount_share $share
    
  done

  return $backup_status
}

run_backup
