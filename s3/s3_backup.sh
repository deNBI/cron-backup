#!/bin/bash

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}
trap 'log "Error occurred, exiting script"; exit 1' ERR
log "Starting backup script"

basedir="/etc/backup"
unencrypted_copy="/etc/unencrypted"
baseEncryptDir="/etc/encrypted"
tmp_conf="/root/tmp.cfg"
tmp_pass="/root/pass.txt"
log "Creating unencrypted directory"
mkdir -p "$unencrypted_copy"

log "Copy data"

cp --verbose -a -u "$basedir/." "$unencrypted_copy"

# Remove duplicate files
log "Removing duplicate files"
fdupes -qdiN -r "$unencrypted_copy"


# Create the encrypted backup directory
log "Creating encrypted backup directory"
mkdir -p "$baseEncryptDir"


# Write the encryption password to a file
log "Writing encryption password to file"
touch "$tmp_pass"
printf "%s" "$S3_ENCRYPT_PASSPHRASE" >> "$tmp_pass"

# Loop through all files in the unencrypted copy
log "Looping through all files in the unencrypted copy"
cd "$unencrypted_copy"
find * -type f | while read -r a; do
  # Skip existing encrypted files
  if [ ! -f "$baseEncryptDir/$a.gpg" ]; then
    if [[ "$a" =~ "/" ]]; then
      dir="$(echo "$a" | rev | cut -d'/' -f2- | rev)"
      mkdir -p "$baseEncryptDir/$dir"
    fi

    # Encrypt the file
    log "Encrypting file $a"
    gpg --batch -o "$baseEncryptDir/$a.gpg" -c --passphrase-file "$tmp_pass" "$a"
  fi
done
rm -f "$tmp_conf" "$tmp_pass"

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

  # Write the S3 configuration to a file
  log "Writing S3 configuration to file"
  touch "$tmp_conf"
  printf "%s\n" "[default]" >> "$tmp_conf"
  printf "%s\n" "access_key = $S3_ACCESS_KEY" >> "$tmp_conf"
  printf "%s\n" "host_base = $S3_OBJECT_STORAGE_EP" >> "$tmp_conf"
  printf "%s\n" "host_bucket = $S3_OBJECT_STORAGE_EP" >> "$tmp_conf"
  printf "%s\n" "secret_key = $S3_SECRET_KEY" >> "$tmp_conf"

  # Create the S3 bucket
  log "Creating S3 bucket $S3_PATH"
  s3cmd -c "$tmp_conf" mb s3://"$S3_PATH"

  # Sync the encrypted files to S3
  log "Syncing encrypted files to S3"
  s3cmd -c "$tmp_conf" -v sync --acl-private "$baseEncryptDir" s3://"$S3_PATH"

  # Remove the temp config and password files
  log "Removing temp config and password files"
  rm -f "$tmp_conf"
done


# Send a notification using the s3_notify_uptime_kuma.sh script
if ! /s3_notify_uptime_kuma.sh; then
  log "Failed to send notification"
fi
