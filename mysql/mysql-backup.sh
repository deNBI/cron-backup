#!/bin/sh


NOW=$(date '+%y-%m-%d-%H%M')
FILE=/etc/backup/${MYSQL_DB}-${NOW}.sql.gz
echo "Create Backup $FILE"

mysqldump -h ${MYSQL_DB} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} --all-databases | gzip > $FILE
