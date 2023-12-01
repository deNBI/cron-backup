#!/bin/sh

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}

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
