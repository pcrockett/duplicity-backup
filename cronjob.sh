#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
VARS_SCRIPT="$SCRIPT_DIR/vars.sh"
RUN_SCRIPT="$SCRIPT_DIR/run.sh"
LOG_FILE="$SCRIPT_DIR/backup-log.txt"

source "$VARS_SCRIPT"

# Ping monitor service to let them know we've started the backup.
# This enables us to have stats about how long the backup takes.
curl -fsS --retry 3 "$PING_URL/start" > /dev/null

BACKUP_STATUS="Failure"
if $RUN_SCRIPT >"$LOG_FILE" 2>&1; then

  BACKUP_STATUS="Success"
  # Ping monitor service to let them know everything went well.
  curl -fsS --retry 3 "$PING_URL" > /dev/null

fi

# Email the log file to the user. We need to run as the backup user,
# because that's the account where the email settings are saved.
sudo -u "$BACKUP_USER" \
  msmtp -a "$SENDER_EMAIL" "$RECIPIENT_EMAIL" \
  <<EOF
Subject: [$NAS_HOST] Backup $BACKUP_STATUS
`cat $LOG_FILE | gpg --armor --sign --encrypt --recipient "$RECIPIENT_KEY"`
EOF
