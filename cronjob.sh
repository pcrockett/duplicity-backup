#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
VARS_SCRIPT="$SCRIPT_DIR/vars.sh"
RUN_SCRIPT="$SCRIPT_DIR/run.sh"
LOG_FILE="$SCRIPT_DIR/backup-log.txt"

source "$VARS_SCRIPT"

curl -fsS --retry 3 "$PING_URL/start" > /dev/null

if $RUN_SCRIPT >"$LOG_FILE" 2>&1; then

  # Success. Email the log file to the user. We need to run as the backup user,
  # because that's the account where the email settings are saved.
  sudo -u "$BACKUP_USER" \
    msmtp -a "$SENDER_EMAIL" "$RECIPIENT_EMAIL" \
    <<EOF
Subject: [$NAS_HOST] Backup Success
`cat $LOG_FILE`
EOF

  curl -fsS --retry 3 "$PING_URL" > /dev/null

else

  # Failure. Email the log file to the user. We need to run as the backup user,
  # because that's the account where the email settings are saved.
  sudo -u "$BACKUP_USER" \
    msmtp -a "$SENDER_EMAIL" "$RECIPIENT_EMAIL" \
  <<EOF
Subject: [$NAS_HOST] Backup Failure
`cat $LOG_FILE`
EOF

fi
