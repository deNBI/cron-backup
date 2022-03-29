#!/bin/sh


NOW=$(date '+%y-%m-%d-%H%M')
FILE=/etc/backup/${MYSQL_HOST}-${NOW}.sql.gz
echo "Create Backup $FILE"

mysqldump -h ${MYSQL_HOST} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} --all-databases | gzip > $FILE
