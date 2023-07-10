#!/bin/sh

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}

NOW=$(date '+%y-%m-%d-%H%M')
FILE=/etc/backup/${MONGODB_DB}-${NOW}.dump.gz
log "Create Backup $FILE"

if [ -n "$MONGODB_USER" ] && [ -n "$MONGODB_PASSWORD" ]; then
  URI="mongodb+srv://$MONGODB_USER:$MONGODB_PASSWORD@$MONGODB_HOST"
else
  URI="mongodb+srv://$MONGODB_HOST"
fi

mongodump --archive=$FILE --gzip --db=$MONGODB_DB --uri="$URI"
