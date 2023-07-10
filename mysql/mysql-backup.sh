#!/bin/sh

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}

NOW=$(date '+%y-%m-%d-%H%M')
FILE=/etc/backup/${MYSQL_HOST}-${NOW}.sql.gz
log "Create Backup $FILE"

mysqldump -h ${MYSQL_HOST} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} --all-databases | gzip > $FILE
