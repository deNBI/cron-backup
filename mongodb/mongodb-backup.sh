#!/bin/sh

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}
trap 'log "Error occurred, exiting script"; exit 1' ERR

NOW=$(date '+%y-%m-%d-%H%M')
FILE="/etc/backup/${MONGODB_DB}-${NOW}.dump.gz"
log "Create Backup $FILE"

if [ -n "$MONGODB_USER" ] && [ -n "$MONGODB_PASSWORD" ]; then
  URI="mongodb://$MONGODB_USER:$MONGODB_PASSWORD@$MONGODB_HOST/$MONGODB_DB"
else
  URI="mongodb://$MONGODB_HOST/$MONGODB_DB"
fi

# Remove the port number from MONGODB_HOST
MONGODB_HOST=$(echo "$MONGODB_HOST" | cut -d: -f1)

mongodump --archive="$FILE" --gzip --uri="$URI"

# Check if the backup file is not empty and has a reasonable size
MIN_SIZE=$((1024 * 10)) # 10KB minimum size
if [ ! -s "$FILE" ] || [ $(stat -c%s "$FILE") -lt $MIN_SIZE ]; then
  log "Backup file $FILE is too small (${MIN_SIZE}B required), aborting script"
  exit 1
fi

# Send a notification using the notify_uptime_kuma.sh script
if ! /notify_uptime_kuma.sh; then
  log "Failed to send notification"
fi
log "Backup completed successfully"