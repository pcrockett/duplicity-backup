#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
VARS_SCRIPT="$SCRIPT_DIR/vars.sh"
RUN_SCRIPT="$SCRIPT_DIR/run.sh"
LOG_FILE="$SCRIPT_DIR/backup-log.txt"

source "$VARS_SCRIPT"

if $RUN_SCRIPT >"$LOG_FILE" 2>&1; then

  msmtp -a "$SENDER_EMAIL" "$RECIPIENT_EMAIL"\
  <<EOF
Subject: [$NAS_HOST] Backup Success
`cat $LOG_FILE`
EOF

  curl -fsS --retry 3 "$PING_URL" > /dev/null

else

  msmtp -a "$SENDER_EMAIL" "$RECIPIENT_EMAIL"\
  <<EOF
Subject: [$NAS_HOST] Backup Failure
`cat $LOG_FILE`
EOF

fi
