#!/bin/sh

NOW=$(date '+%y-%m-%d-%H%M')

FILE=/etc/backup/db-${NOW}.sql.gz
mysqldump -h limesurvey_db -u root -p ${LIMESURVEY_DB_PASSWORD} --all-databases| gzip > $FILE