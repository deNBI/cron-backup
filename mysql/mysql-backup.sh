#!/bin/sh

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}
trap 'log "Error occurred, exiting script"; exit 1' ERR

NOW=$(date '+%y-%m-%d-%H%M')
FILE=/etc/backup/${MYSQL_HOST}-${NOW}.sql.gz
log "Create Backup $FILE"

mysqldump -h ${MYSQL_HOST} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} --all-databases | gzip > $FILE

# Check if the backup file is not empty and has a reasonable size
MIN_SIZE=$((1024 * 10)) # 10KB minimum size
if [ ! -s "$FILE" ] || [ $(stat -c%s "$FILE") -lt $MIN_SIZE ]; then
  log "Backup file $FILE is too small (${MIN_SIZE}B required), aborting script"
  exit 1
fi

# Send a notification using the notify_uptime_kuma.sh script
if ! ./notify_uptime_kuma.sh; then
  log "Failed to send notification"
fi
log "Backup completed successfully"