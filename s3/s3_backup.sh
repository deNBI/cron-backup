#!/bin/bash
set -Eeuo pipefail
IFS=$'\n\t'

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}

trap 'log "Error occurred, exiting script"; exit 1' ERR
cleanup() {
    rm -f "${tmp_conf:-}" "${tmp_pass:-}"
}

trap cleanup EXIT

log "Starting backup script"
# Required variables
: "${S3_ENCRYPT_PASSPHRASE:?Missing S3_ENCRYPT_PASSPHRASE}"
: "${S3_CONFIGS_PATH:?Missing S3_CONFIGS_PATH}"

basedir="/etc/backup"
unencrypted_copy="/etc/unencrypted"
baseEncryptDir="/etc/encrypted"

tmp_conf=$(mktemp)
tmp_pass=$(mktemp)

chmod 600 "$tmp_conf" "$tmp_pass"

log "Creating unencrypted directory"
mkdir -p "$unencrypted_copy"

log "Copy data"

cp --verbose -a -u "$basedir/." "$unencrypted_copy"

# Remove duplicate files
log "Removing duplicate files"
fdupes -qdiN -r "$unencrypted_copy" || true


# Create the encrypted backup directory
log "Creating encrypted backup directory"
mkdir -p "$baseEncryptDir"


# Write the encryption password to a file
log "Writing encryption password to file"
printf "%s" "$S3_ENCRYPT_PASSPHRASE" > "$tmp_pass"

pass_length=${#S3_ENCRYPT_PASSPHRASE}
log "Encryption passphrase length: ${pass_length}"
log "Encrypting files"

cd "$unencrypted_copy"
find . -type f -print0 | while IFS= read -r -d '' file; do

    a="${file#./}"

    src="$unencrypted_copy/$a"
    dst="$baseEncryptDir/$a.gpg"
    tmp="$dst.tmp"


    mkdir -p "$(dirname "$dst")"


    # Skip unchanged encrypted files
    if [[ -f "$dst" && "$dst" -nt "$src" ]]; then
        log "Skipping unchanged file: $a"
        continue
    fi


    log "Encrypting: $a"

    log "Source size: $(du -h "$src" | cut -f1)"


    rm -f "$tmp"


    if gpg \
        --batch \
        --yes \
        --pinentry-mode loopback \
        --passphrase-file "$tmp_pass" \
        -c \
        -o "$tmp" \
        "$src"
    then

        mv -f "$tmp" "$dst"

        log "Encrypted size: $(du -h "$dst" | cut -f1)"

    else

        log "Encryption failed: $a"
        rm -f "$tmp" "$dst"

    fi

done

# Loop through all config files
log "Looping through all config files"
find "$S3_CONFIGS_PATH" -type f -name "*.cfg" | while read -r env_data; do
  config_name="$(basename -- "$env_data")"
  site_name="${config_name%.*}"

  # Load the environment data
  log "Loading environment data from $env_data"
  . "$env_data"

  # Remove the temp config and password files
  log "Removing temp config and password files"
  rm -f "$tmp_conf"

    log "Creating temporary s3cmd config"


    cat > "$tmp_conf" <<EOF
[default]
access_key = $S3_ACCESS_KEY
secret_key = $S3_SECRET_KEY
host_base = $S3_OBJECT_STORAGE_EP
host_bucket = $S3_OBJECT_STORAGE_EP
EOF


    chmod 600 "$tmp_conf"

  # Create the S3 bucket
  log "Creating S3 bucket $S3_PATH"
  s3cmd -c "$tmp_conf" mb s3://"$S3_PATH" || true

  # Sync the encrypted files to S3
  log "Syncing encrypted files to S3"
  s3cmd -c "$tmp_conf" -v sync --acl-private "$baseEncryptDir" s3://"$S3_PATH"

    log "Finished upload for $site_name"
done

log "Sending Kuma notification"
# Send a notification using the s3_notify_uptime_kuma.sh script
if ! /s3_notify_uptime_kuma.sh; then
  log "Failed to send notification"
fi
log "Backup finished successfully"
