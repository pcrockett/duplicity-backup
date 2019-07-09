#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

read -p "NAS hostname: " host
read -p "NAS username: " username
read -p "NAS password: " password
read -p "Root mount directory: " mount_dir
read -p "Backblaze master key ID: " b2_key_id
read -p "Backblaze key: " b2_key
read -p "Backblaze bucket: " b2_bucket
read -p "Encryption / signing key fingerprint: " gpg_key
read -p "Offline GPG key: " offline_gpg_key

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
VARS_SCRIPT="$SCRIPT_DIR/vars.sh"

cat > "$VARS_SCRIPT" << EOF
#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

export NAS_HOST="$host"
export NAS_USERNAME="$username"
export NAS_PASSWORD="$password"
export MOUNT_DIR=$mount_dir
export B2_KEY_ID="$b2_key_id"
export B2_KEY="$b2_key"
export B2_BUCKET="$b2_bucket"
export GPG_KEY="$gpg_key"
export GPG_OFFLINE_KEY="$offline_gpg_key"
export SHARES=(
  # Add shares here
)
EOF

chmod u+x "$VARS_SCRIPT"

echo "Installed. Add shares and modify configuration by editing $VARS_SCRIPT"
