#!/bin/sh

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}
trap 'log "Error occurred, exiting script"; exit 1' ERR

touch ~/.pgpass
log "Creating ~/.pgpass file"
echo ${POSTGRES_HOST}:${POSTGRES_PORT}:${POSTGRES_DB}:${POSTGRES_USER}:${POSTGRES_PASSWORD} > ~/.pgpass
chmod 600 ~/.pgpass

export PGPASSFILE='/root/.pgpass'

NOW=$(date '+%y-%m-%d-%H%M')
FILE=/etc/backup/${POSTGRES_DB}-${NOW}.dump.gz
log "Create Backup $FILE"

pg_dump -h ${POSTGRES_HOST} -U ${POSTGRES_USER} ${POSTGRES_DB} -Z 9 > $FILE

# Check if the backup file is not empty and has a reasonable size
MIN_SIZE=$((1024 * 10)) # 10KB minimum size
if [ ! -s "$FILE" ] || [ $(stat -c%s "$FILE") -lt $MIN_SIZE ]; then
  log "Backup file $FILE is too small (${MIN_SIZE}B required), aborting script"
  exit 1
fi

/notify_uptime_kuma.sh || log "Failed to send notification"

log "Backup completed successfully"